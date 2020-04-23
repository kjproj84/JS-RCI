#!/usr/bin/env node
/*
 * Copyright 2014 Samsung Information Systems America, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *        http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// Author: Koushik Sen
// Author: Manu Sridharan

/*jslint node: true */
/*global process */
/*global J$ */

var argparse = require('argparse');
var instUtil = require('../instrument/instUtil');
var parser = new argparse.ArgumentParser({
    addHelp: true,
    description: "Command-line utility to perform Jalangi2's instrumentation and analysis"
});
parser.addArgument(['--analysis'], {help: "absolute path to analysis file to run", action: 'append'});
parser.addArgument(['--initParam'], { help: "initialization parameter for analysis, specified as key:value", action:'append'});
parser.addArgument(['--inlineIID'], {help: "Inline IID to (beginLineNo, beginColNo, endLineNo, endColNo) in J$.iids in the instrumented file", action: 'storeTrue'});
parser.addArgument(['--inlineSource'], {help: "Inline original source as string in J$.iids.code in the instrumented file", action: 'storeTrue'});
parser.addArgument(['--astHandlerModule'], {help: "Path to a node module that exports a function to be used for additional AST handling after instrumentation"});
parser.addArgument(['script_and_args'], {
    help: "script to record and CLI arguments for that script",
    nargs: argparse.Const.REMAINDER
});
var args = parser.parseArgs();
var astHandler = null;
if (args.astHandlerModule) {
    astHandler = require(args.astHandlerModule);
}



if (args.script_and_args.length === 0) {
    console.error("must provide script to record");
    process.exit(1);
}
// we shift here so we can use the rest of the array later when
// hacking process.argv; see below
var script = args.script_and_args.shift();

var Module = require('module');
var path = require('path');
var fs = require('fs');
var originalLoader = Module._extensions['.js'];
var FILESUFFIX1 = "_jalangi_";

function makeInstCodeFileName(name) {
    return name.replace(/.js$/, FILESUFFIX1 + ".js").replace(/.html$/, FILESUFFIX1 + ".html");
}

function makeSMapFileName(name) {
    return name.replace(/.js$/, ".json");
}

acorn = require("acorn");
esotope = require("esotope");
require('../headers').headerSources.forEach(function (header) {
    require("./../../../" + header);
});

var initParam = null;
if (args.initParam) {
    initParam = {};
    args.initParam.forEach(function (keyVal) {
        var split = keyVal.split(':');
        if (split.length !== 2) {
            throw new Error("invalid initParam " + keyVal);
        }
        initParam[split[0]] = split[1];
    });
}
J$.initParams = initParam || {};
if (args.analysis) {
    args.analysis.forEach(function (src) {
        require(path.resolve(src));
    });
}

J$.JSRCI={};
J$.snapshots=[];
J$.snapshots.push({});
J$.toRollback = false;
// J$.snapshots[0][105]=5555;
J$.rollbacks = {};
J$.methods = {};
J$.JSRCI_var = 11111;
var under_=require("underscore");
var colors = require("colors/safe");
var _ = require('lodash');
var esprima = require('esprima');
function removeMeta(obj) {
  for(prop in obj) {
    if (JSON.stringify(obj[prop])=="{}") {
        // delete obj[prop];
      obj[prop] = undefined;
    }
    else if (typeof obj[prop] === 'object')
      removeMeta(obj[prop]);
  }
}

J$.isEqual = _.isEqual;
J$.merge = _.merge;
J$.removeMeta = removeMeta;
J$.underClone = under_.clone;
J$.regular = /\((.+):(.+):(.+):(.+):(.+)\)/g;
J$.clone = function (thing, opts) {
    var newObject = {};
    if (thing instanceof Array) {
        return thing.map(function (i) { return J$.clone(i, opts); });
    } else if (thing instanceof Date) {
        return new Date(thing);
    } else if (thing instanceof RegExp) {
        return new RegExp(thing);
    }
    // else if (thing instanceof Function) {
    //     return opts && opts.newFns ?
    //                new Function('return ' + thing.toString())() :
    //                thing;
    // }
    else if (thing instanceof Object) {
        //console.log(thing,"----------------------------\n",Object.keys(thing));
        Object.keys(thing).forEach(function (key) {
           // if(thing[key]!="undefined")
            try {

                newObject[key] = J$.clone(thing[key], opts);
            }catch (e){
                //console.log(key,":" ,typeof  thing[key],":", thing[key]);
            }

        });
        return newObject;
    } else if ([ undefined, null ].indexOf(thing) > -1) {
        return thing;
    } else {
        if (thing.constructor.name === 'Symbol') {
            return Symbol(thing.toString()
                       .replace(/^Symbol\(/, '')
                       .slice(0, -1));
        }
        // return _.clone(thing);  // If you must use _ ;)
        return thing.__proto__.constructor(thing);
    }
};

J$.IsJsonFormat	= function(obj){
		try{
			var str = JSON.stringify(obj);
			return (typeof str === 'string');
		}catch(e){
			return false;
		}
	}
var falafel = require('falafel');
var escodegen = require('escodegen');
var lineColumn = require("line-column");

function findCalee(id, code){

                var location = J$.iids[id];
                var b_ = lineColumn(code).toIndex(location[0], location[1]);
                var e_ = lineColumn(code).toIndex(location[2], location[3]);

                var myast = esprima.parseScript(code.slice(b_, e_), {range:true });
                var myrange = myast.body[0].expression.callee.range;
                var calleename = code.slice(b_, e_).slice(myrange[0],myrange[1]);

    return {calleename:calleename, myast:myast, orig:code.slice(b_, e_)};
}

Module._extensions['.js'] = function (module, filename) {
    var code = fs.readFileSync(filename, 'utf8');
    var instFilename = makeInstCodeFileName(filename);
    var instCodeAndData= J$.instrumentCode(
        {
            code: code,
            isEval: false,
            origCodeFileName: filename,
            instCodeFileName: instFilename,
            inlineSourceMap: !!args.inlineIID,
            inlineSource: !!args.inlineSource
        });
    
    instUtil.applyASTHandler(instCodeAndData, astHandler, J$);
    fs.writeFileSync(makeSMapFileName(instFilename), instCodeAndData.sourceMapString, "utf8");


    var iids ="";


    var normalized = falafel(instCodeAndData.code, function (node1) {
        //if (node1.type === 'ExpressionStatement' && node1.expression.type==='AssignmentExpression' &&  node1.expression.left &&  node1.expression.left.object && node1.expression.left.object.name=="J$" && node1.expression.left.property.name=="iid"
        if (!instFilename.includes("node_modules") && node1.type === 'ExpressionStatement' && node1.expression.type==='AssignmentExpression' && node1.expression.left &&  node1.expression.left.object && node1.expression.left.object.name=="J$" && node1.expression.left.property && node1.expression.left.property.name=="iids"

        ) {
           // console.log("@@@@@@@@   ", escodegen.generate(node1).slice(0, Math.min(escodegen.generate(node1).length, 40)));
            iids = escodegen.generate(node1);
            eval(iids);
        }

    if(!instFilename.includes("node_modules") && node1.type==='IfStatement' && node1.consequent.type!=='BlockStatement')
    {
        node1.consequent.update("{"+node1.consequent.source()+"}");
        // console.log("testing", node1);
        var alternative = node1.alternate;
        while(alternative!=undefined){
            // console.log(alternative);
            // if(alternative.consequent && alternative.consequent.type !=='BlockStatement'){
          //  alternative.consequent.update("{"+alternative.consequent.source()+"}");
          //   }
             if(alternative.consequent==undefined && alternative.type !=='BlockStatement' && alternative.source()[0]!="{"){
              //   console.log("@@@@@",alternative.source(),alternative.start, alternative.end, alternative.source()[0]);
                alternative.update("{"+alternative.source()+"}");

            }

             alternative = alternative.alternate;

            //next = consequent;
        }

    }

    });

    //Instrumenting SQL Invocations, rewriting before and after of Method Invocations
    var sqlInvokeInstrumented = falafel(normalized.toString(), function (node) {
         try {
     if (node.type === 'ExpressionStatement' &&
         node.expression.callee && node.expression.callee.property && node.expression.callee.property.name=="X1"
          && node.expression.arguments[1]  && node.expression.arguments[1].callee && node.expression.arguments[1].callee.callee
            && node.expression.arguments[1].callee.callee.property
         // && node.expression.arguments[1].callee.arguments[0].value==2465
         && !instFilename.includes("node_modules")
           // && node.expression.arguments[0].value == 2465
         && node.expression.arguments[1].callee.callee.property.name =="M"
     ) {//Insturmenting-code for MethodInvocation, bottom-up
         // var id = node.expression.arguments[1].callee.arguments[0].value;
             var id = node.expression.arguments[0].value;
             // console.log("@@@", node.expression.arguments[0].value, calleename, code.slice(b_,e_), node);
             var foundCallee = findCalee(id, code);
             var beforecallee = foundCallee.calleename;
             var mycallee = beforecallee.replace(/ *\([^)]*\) */g, "");
             // console.log("@@@",beforecallee, mycallee);
             var parent = node.parent;
             var nested = false;
             while (parent) {
                 if (parent.type === 'ExpressionStatement') {
                     var pid = parent.expression.arguments[0].value;
                     var pbeforecallee = findCalee(pid, code).calleename;
                     var pmycallee = pbeforecallee.replace(/ *\([^)]*\) */g, "");
                     // console.log("###",pid, ppc, pmycallee, pmycallee==mycallee);
                 }
                 if (pmycallee == mycallee) {//nested calls then skip it.
                     console.log(colors.grey("###nested! skipped!", pid, beforecallee, pbeforecallee, pmycallee, pmycallee == mycallee));
                     nested = true;
                     break;
                 }
                 parent = parent.parent;
             }//checking nested query

             if (!nested) {
                 var args_ = [];

//                location = filename+":"+location.join(":");
                 var myast = foundCallee.myast;
                 var text1 = "", text2 = "";
                 // console.log("matched",beforecallee.match(/ *\([^)]*\) */g), beforecallee.match(/ *\([^)]*\) */g)!=null);
                 if (beforecallee.match(/ *\([^)]*\) */g)!=null && myast.body[0].expression.callee.object) {




                     // console.log("#########",myast.body[0].expression.callee.object.arguments);
                     for (var j in myast.body[0].expression.callee.object.arguments) {
                         // myast.body[0].expression.arguments[j];
                         var arg_ = myast.body[0].expression.callee.object.arguments[j];
                         if (arg_.type !== "FunctionExpression") {
                             if (arg_.type === "Literal") {
                                 args_.push(`typeof ${arg_.raw} == \'string\' && (JSON.stringify(${arg_.raw}).includes(\"FROM\")||JSON.stringify(${arg_.raw}).includes(\"From\"))`);
                             } else if (arg_.name != "event") {
                                 args_.push(`typeof ${arg_.name} == \'string\' && (JSON.stringify(${arg_.name}).includes(\"FROM\")||JSON.stringify(${arg_.name}).includes(\"From\"))`);
                             }
                         }

                     }



                     text1 = beforecallee.replace(/ *\([^)]*\) */g, "(\"begin TRANSACTION\")") + "();";
                     // console.log(text1);
                     text1 = text1 + "\nconsole.log(\"#$#$#$#start TRANSACTION\");";
                     // text1 = beforecallee + "(\"start TRANSACTION\", function (arg1, arg2, arg3) {console.log(\"#$#$#$#start TRANSACTION\");})";
                     //
                     text2 = beforecallee.replace(/ *\([^)]*\) */g, "(\"ROLLBACK\")") + "();";
                     text2 = text2 + "\nconsole.log(\"#$#$#$# ROLLBACK\");";
                 //    console.log(id, colors.green("//SQL INVOCATION\n" + "if(" + args_.join(" || ") + "&& J$.toRollback){\n" + text1 + "\n       }\n\n" + foundCallee.orig + "//SQL ROOOOOOOOOOOOOLLBACK\nif(" + args_.join(" || ") + "&& J$.toRollback){\n" + text2 + "\n       }\n" + "\n    "));

                     node.update("//SQL INVOCATION\n" + "if(" + args_.join(" || ") + "&& J$.toRollback){\n" + text1 + "\n       }\n\n" + node.source() + "//SQL ROOOOOOOOOOOOOLLBACK\nif(" + args_.join(" || ") + "&& J$.toRollback){\n" + text2 + "\n       }\n" + "\n    ");

                 }
                 else {

                     // var myast = foundCallee.myast;
                     for (var j in myast.body[0].expression.arguments) {
                         // myast.body[0].expression.arguments[j];
                         var arg_ = myast.body[0].expression.arguments[j];
                         if (arg_.type !== "FunctionExpression") {
                             if (arg_.type === "Literal") {
                                 args_.push(`typeof ${arg_.raw} == \'string\' && (JSON.stringify(${arg_.raw}).includes(\"FROM\")||JSON.stringify(${arg_.raw}).includes(\"From\"))`);
                             } else if (arg_.name != "event") {
                                 args_.push(`typeof ${arg_.name} == \'string\' && (JSON.stringify(${arg_.name}).includes(\"FROM\")||JSON.stringify(${arg_.name}).includes(\"From\"))`);
                             }
                         }

                     }
                     // var text1 = calleename+"(\"start TRANSACTION\", function (arg1, arg2, arg3) {console.log(\"#$#$#$#start TRANSACTION\",arg1, arg2, arg3);})";
                     text1 = beforecallee + "(\"start TRANSACTION\", function (arg1, arg2, arg3) {console.log(\"#$#$#$#start TRANSACTION\");})";
                     // var text2 = calleename+"(\"ROLLBACK\", function (arg1, arg2, arg3) {console.log(\"#$#$#$#ROLLBACK\",arg1, arg2, arg3);})";
                     var text2 = beforecallee + "(\"ROLLBACK\", function (arg1, arg2, arg3) {console.log(\"#$#$#$#ROLLBACK\");})";
                  //   console.log(colors.blue(text1, "\n", text2));
                     if(args_.length >0) {
                         console.log(id, colors.blue("//SQL INVOCATION\n" + "if(" + args_.join(" || ") + "&& J$.toRollback){\n" + text1 + "\n       }\n\n" + foundCallee.orig + "//SQL ROOOOOOOOOOOOOLLBACK\nif(" + args_.join(" || ") + "&& J$.toRollback){\n" + text2 + "\n       }\n" + "\n    "));
                         node.update("//SQL INVOCATION\n" + "if(" + args_.join(" || ") + "&& J$.toRollback){\n" + text1 + "\n       }\n\n" + node.source() + "//SQL ROOOOOOOOOOOOOLLBACK\nif(" + args_.join(" || ") + "&& J$.toRollback){\n" + text2 + "\n       }\n" + "\n    ");
                        //node.update("              if("+args_.join(" || ")+"){\n" +text2 +"\n       }\n"+"\n    "+node.source());
                        // node.update("\n    J$.methods.f"+node.expression.arguments[1].callee.arguments[0].value+"="+beforecallee+";\n    "+node.source());
                    }
                 }


             }

     }


     /**before version, none-nesting
    if (node.type === 'ExpressionStatement' && node.expression.callee && node.expression.callee.property && node.expression.callee.property.name=="X1"
        && node.expression.arguments[1]  && node.expression.arguments[1].callee && node.expression.arguments[1].callee.callee
            && node.expression.arguments[1].callee.callee.property && node.expression.arguments[1].callee.callee.property.name =="M"
         //   && node.expression.arguments[1].callee.arguments[0].value==689
            && !instFilename.includes("node_modules")
        ) {
            try {
                eval(iids);
                var id = node.expression.arguments[1].callee.arguments[0].value;
                var location = J$.iids[id];
                var b_ = lineColumn(code).toIndex(location[0], location[1]);
                var e_ = lineColumn(code).toIndex(location[2], location[3]);

                var myast = esprima.parseScript(code.slice(b_, e_), {range:true });
                var myrange = myast.body[0].expression.callee.range;
                var calleename = code.slice(b_, e_).slice(myrange[0],myrange[1]);

                var args_=[];
                for(var j in myast.body[0].expression.arguments){
                    // myast.body[0].expression.arguments[j];
                    var arg_ = myast.body[0].expression.arguments[j];
                    if(arg_.type !=="FunctionExpression") {
                        if(arg_.type ==="Literal"){
                            args_.push(`typeof ${arg_.raw} == \'string\' && (JSON.stringify(${arg_.raw}).includes(\"FROM\")||JSON.stringify(${arg_.raw}).includes(\"From\"))`);
                        }else if(arg_.name!="event"){
                        args_.push(`typeof ${arg_.name} == \'string\' && (JSON.stringify(${arg_.name}).includes(\"FROM\")||JSON.stringify(${arg_.name}).includes(\"From\"))`);
                        }
                    }

                }
//                location = filename+":"+location.join(":");

                // var text1 = calleename+"(\"start TRANSACTION\", function (arg1, arg2, arg3) {console.log(\"#$#$#$#start TRANSACTION\",arg1, arg2, arg3);})";
                var text1 = calleename+"(\"start TRANSACTION\", function (arg1, arg2, arg3) {console.log(\"#$#$#$#start TRANSACTION\");})";
                // var text2 = calleename+"(\"ROLLBACK\", function (arg1, arg2, arg3) {console.log(\"#$#$#$#ROLLBACK\",arg1, arg2, arg3);})";
                var text2 = calleename+"(\"ROLLBACK\", function (arg1, arg2, arg3) {console.log(\"#$#$#$#ROLLBACK\");})";
                console.log(colors.blue(text1, "\n", text2));
                if(args_.length >0) {
                    node.update("//SQL INVOCATION\n" + "if(" + args_.join(" || ") + "&& J$.toRollback){\n" + text1 + "\n       }\n\n" + node.source() + "//SQL ROOOOOOOOOOOOOLLBACK\nif(" + args_.join(" || ") + "&& J$.toRollback){\n" + text2 + "\n       }\n" + "\n    ");
                    //node.update("              if("+args_.join(" || ")+"){\n" +text2 +"\n       }\n"+"\n    "+node.source());
                    //node.update("\n    J$.methods.f"+node.expression.arguments[1].callee.arguments[0].value+"="+calleename+";\n    "+node.source());
                }
            } catch(e){}
        }
      //before version, none-nesting
      **/

 } catch (e) {
            console.err(node.source());

         }
    });

    //Instrumenting Global Variables
    var globalVarInstrumented = falafel(sqlInvokeInstrumented.toString(), function (node) {
        //Adding for save states and restore states for Global Variable Declarations
        // if (node.type === 'VariableDeclaration' ) {
          if (node.type === 'VariableDeclaration' && !instFilename.includes("node_modules")) {
             //if(node.parent.parent.parent.parent.parent.parent && node.declarations[0].id.name &&node.declarations[0].init &&node.declarations[0].init.arguments && node.declarations[0].init.arguments[0].value && node.declarations[0].id.name=="JSRCI_var")
            //if(node.parent.parent.parent.parent.parent.parent.type=='Program' && node.declarations[0].id.name &&node.declarations[0].init &&node.declarations[0].init.arguments && node.declarations[0].init.arguments[0].value&& node.declarations[0].init.arguments[0].value == 105 )
        if(node.parent.parent.parent.parent.parent.parent.type=='Program' && node.declarations[0].id.name &&node.declarations[0].init &&node.declarations[0].init.arguments && node.declarations[0].init.arguments[0].value )
            {
                //J$.snapshots[0][node.declarations[0].init.arguments[0].value]
                //console.log("@@@@@@@@   ",node);
                //console.log("@@@@@@@@   ",escodegen.generate(node));
                //console.log("@@@@@@@@##   ",node.declarations[0].id.name);
                //VARNAME+"=J$.merge(jsrci_temp,"+ELEMENT+");"+
                // "console.log(\"@@@@@@@@@@@@@@@@@@@@@@@@@@@\",,"+VARNAME+","+ELEMENT+",\n\"---------------------\",J$.merge(jsrci_temp,"+ELEMENT+"));}";
//                  var ELEMENT= "J$.snapshots[0]["+node.declarations[0].init.arguments[0].value+"]";

                  var ELEMENT2= "J$.snapshots[0]["+node.start+node.end+node.declarations[0].init.arguments[0].value+"]";
                  var COND1 = "if("+ELEMENT2+"==undefined && (typeof "+ELEMENT2+")!=\'function\' && J$.IsJsonFormat("+node.declarations[0].id.name+"))";
                  var COND2 = "if("+ELEMENT2+"!=undefined && (typeof "+ELEMENT2+")!=\'function\' && J$.IsJsonFormat("+node.declarations[0].id.name+"))";
                  var VARNAME = node.declarations[0].id.name;
                //snapshot for the initial state
                var takingshot ="\n//TAKING SNAPSHOT \n           "+COND1+"{" +
                    //"\n              var jsrci_temp = J$.underClone("+VARNAME+"); "+ELEMENT+"=J$.clone(jsrci_temp); "+" J$.removeMeta("+ELEMENT+");  "+ELEMENT+".abc=9;" +
                    "\n              var jsrci_temp = J$.underClone("+VARNAME+"); "+ELEMENT2+"=J$.clone(jsrci_temp); "+" J$.removeMeta("+ELEMENT2+");"+
                    "\n\n                 if(!J$.isEqual("+VARNAME+",J$.merge(jsrci_temp,"+ELEMENT2+"))){\n                     delete "+ELEMENT2+"\n                 }"+
                    "\n           }"

                var rollback_func="\n//ADDING rollback Fuction\n            J$.rollbacks.f"+ node.start+node.end+node.declarations[0].init.arguments[0].value +"=function (){\n                 " +
                          COND2+"{"+
                        // "console.log(\'###########\',typeof "+VARNAME+","+ELEMENT2+","+VARNAME+");\n"+
                         "\n                    var jsrci_temp = J$.underClone("+VARNAME+");\n"+
                            "\n                     if(typeof "+VARNAME+"==\'object\'){\n                       "+
                            VARNAME+"=J$.merge("+VARNAME+","+ELEMENT2+");" +
                    "       \n                     }else{\n                      " +
                            VARNAME+"="+ELEMENT2+";"+

                    "\n                     }" +
                    "\n                 }"+
                    "\n            }";
                //Updating global VarDecl nodes
                node.update("\n    "+node.source()+"\n"+takingshot+"\n"+rollback_func);
            }
        }
    });

    // instCodeAndData.code
    // fs.writeFileSync(instFilename, instCodeAndData.code, "utf8");
    // module._compile(instCodeAndData.code, filename);
// console.log("@@@@@@@@@@@@@@@@@@@",instFilename);
    // if(instFilename.includes("node_modules")) {
    //     console.log("@@@@@@@@@@@@@@@@@@@");
    //     fs.writeFileSync(instFilename, instCodeAndData.code, "utf8");
    //     module._compile(instCodeAndData.code, filename);
    // }else{
        fs.writeFileSync(instFilename, globalVarInstrumented.toString(), "utf8");
        module._compile(globalVarInstrumented.toString(), filename);
    // }

    // J$._compile = module._compile;

};

function startProgram() {
    // hack process.argv for the child script
    script = path.resolve(script);
    var newArgs = [process.argv[0], script];
    newArgs = newArgs.concat(args.script_and_args);
    process.argv = newArgs;
    // this assumes that the endExecution() callback of the analysis
    // does not make any asynchronous calls
    process.on('exit', function () { J$.endExecution(); });
    Module.Module.runMain(script, null, true);

}

if (J$.analysis && J$.analysis.onReady) {
    J$.analysis.onReady(startProgram);
} else {
    startProgram();
}
