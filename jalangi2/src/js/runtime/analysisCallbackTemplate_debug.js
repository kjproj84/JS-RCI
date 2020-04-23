/*
FROM jalangi2/src/js/runtime/analysisCallbackTemplate.js

// do not remove the following comment
// JALANGI DO NOT INSTRUMENT

 */

var sqlInvocations =[];
var exitPointMap = {};
var getFieldsMap = {};
var entryPointMap = {};
var entryPointValMap = {};
var passedEntry = false;
var path = require('path');
var format = require("string-template");
var polycrc = require('polycrc');
var constraints_solver = require('../../../../src/Insourcing')
var uuid = 0;
J$.mashallingLog ={};
J$.mashallingLog.sqlInvocations=[];
J$.mashallingLog.sqlInvocationsloc=[];
J$.mashallingLog.sqls=[];
var escodegen = require('escodegen');

// var insourcing = require('src/dummyInsourcing');
J$.sqlInvocationsMap ={};
var lineColumn = require("line-column");
J$.toRollback = false;
//J$.toRollback = false;
var colors = require("colors/safe");
var fs = require('fs');
var underscore = require('underscore');
var esprima = require('esprima');
var estraverse = require('estraverse');
const { parse } = require('json2csv');
//var csvData = parse(JSON.parse(JSON.stringify(args[1])));
var code = fs.readFileSync("./test1.json").toString();
var aaa = JSON.parse(code);
console.log(JSON.stringify(aaa));
//console.log("parsejson2csv", parse );
var NUM = 9999;
const { Parser } = require('node-sql-parser');
const sqlParser = new Parser();
//const save_table = 'SELECT * FROM recipes';
J$.SAVE_TABLE = "SELECT * FROM recipes";

var gen_rw_inputs={};

function aabbba(a1, b1) {
jalangiLabel1026:
    while (true) {
        try {
            J$.Fe(193, arguments.callee, this, arguments);
            arguments = J$.N(201, 'arguments', arguments, 4);
            a1 = J$.N(209, 'a1', a1, 4);
            b1 = J$.N(217, 'b1', b1, 4);
            J$.X1(161, JSRCI_var = J$.W(153, 'JSRCI_var', J$.R(145, 'a1', a1, 0), JSRCI_var, 2));
            J$.X1(185, JSRCI_ob = J$.W(177, 'JSRCI_ob', J$.R(169, 'b1', b1, 0), JSRCI_ob, 2));
        } catch (J$e) {
            J$.Ex(2969, J$e);
        } finally {
            if (J$.Fr(2977))
                continue jalangiLabel1026;
            else
                return J$.Ra();
        }
    }
}


(function (sandbox) {
    var MAX_STRING_LENGTH = 20;
	function IsJsonFormat(obj){
		try{
			var str = JSON.stringify(obj);
			return (typeof str === 'string');
		}catch(e){
			return false;
		}
	}

	// use this recursive function with a parse funciton
    function parseObjectProperties (obj, parse) {
      for (var k in obj) {
        if (typeof obj[k] === 'object' && obj[k] !== null) {
          parseObjectProperties(obj[k], parse)
        } else if (obj.hasOwnProperty(k)) {
          parse(obj[k])
        }
      }
    }
	function hasEqualInput(obj,output){
		for (var i in aaa){
			if(underscore.isEqual(aaa[i].client_params,obj) && underscore.isEqual(aaa[i].server_return,output)){
				return aaa[i].id;
			}
		}

		return undefined;

	}
	function hasEqual(obj){
		for (var i in aaa){
			if(underscore.isEqual(aaa[i].server_return,obj)){
				return aaa[i].id; 
			}
		}

		return undefined;
		
	}

	function hasEqualinParam(obj){
		for (var i in aaa){
			if(underscore.isEqual(aaa[i].client_params,obj)){
				return aaa[i].id;
			}
		}

		return undefined;

	}

        function getValue(v) {
            var type = typeof v;
	   // if(type ==='number' || (type === 'string' && type === parseInt(v))) return parseInt(v);
            if ((type === 'object' || type ==='function') && v!== null) {
                var shadowObj = sandbox.smemory.getShadowObjectOfObject(v);
                return type+"(id="+sandbox.smemory.getIDFromShadowObjectOrFrame(shadowObj)+")";
            } else {
                if (type === 'string' && v.length> MAX_STRING_LENGTH) {
                    v = v.substring(0,MAX_STRING_LENGTH)+"...";
                }
                return JSON.stringify(v);
            }
        }


   
    function MyAnalysis() {
        this.invokeFunPre = function (iid, f, base, args, isConstructor, isMethod, functionIid, functionSid) {
            var id = J$.getGlobalIID(iid);
            var location = J$.iidToLocation(id);
            var aaa = /\((.+):(.+):(.+):(.+):(.+)\)/g.exec(location);

            if(aaa !=null && aaa.length == 6 &&(!aaa[1].includes("node_modules"))){
                var code = fs.readFileSync(aaa[1]).toString();

                var pos = lineColumn(code).toIndex(aaa[2], aaa[3]);
                var end =  lineColumn(code).toIndex(aaa[4], aaa[5]);
                var fff = code.slice(pos, end);
                var ast_program = esprima.parse(code,{ loc: true, range: true });
                if((typeof args[0]==='string')&& (args[0].includes("from")||args[0].includes("insert")||args[0].includes("update")) ){//found sql invocation
                    var sqlText = args[0].replace("?","-1");
                    var ast1 = "", tablename ="TABLE";
                    try{
                        console.log("sqlText", uuid, sqlText, location,pos, end, "#$#$#$",fff);
                        ast1 = sqlParser.astify(sqlText);
                        tablename = ast1.from[0].table;
                    } catch (e){}


                      estraverse.traverse(ast_program, {
                            enter: function (node, parent) {
                                node.parent = parent;
                                if (node.type ==="CallExpression" && node.range[0]==pos && node.range[1]==end){
                                    console.log("_________________________CallExpression",code.slice(pos, end));
                                    var myparent =parent;
                                    while(myparent){
                                        if(myparent.type==="ExpressionStatement") {
                                            console.log("_________________________ExpressionStatement", code.slice(myparent.range[0], myparent.range[1]));
                                            if(myparent.expression && myparent.expression.arguments && myparent.expression.arguments[0].type ==="FunctionExpression" && myparent.expression.arguments[0].params[0] ){
                                            }
                                            var ast = esprima.parse(fff,{ loc: true, range: true });
                                            if(ast.body[0].expression && ast.body[0].expression.arguments[0]){


                                                var adaptedsqlInvocation11="";
                                                if(myparent.expression.arguments[0].params[0]){
                                                    console.log("_________________________ExpressionStatement", myparent.expression.arguments[0].params[0].name, ast.body[0].expression.arguments[0].name);
                                                    adaptedsqlInvocation11=format("code[hashVar[\"{0}:{1}:{2}\"][\"bin\"]]=\"var {3}=alasql({4});\"",[
                                                        aaa[1].replace(process.cwd()+"/",''),
                                                        myparent.range[0],
                                                        myparent.range[1],
                                                        myparent.expression.arguments[0].params[0].name,
                                                        ast.body[0].expression.arguments[0].name]
                                                    );
                                                }else{
                                                    console.log("_________________________ExpressionStatement", ast.body[0].expression.arguments[0].name);
                                                    adaptedsqlInvocation11=format("code[hashVar[\"{0}:{1}:{2}\"][\"bin\"]]=\"alasql({3});\"",[
                                                        aaa[1].replace(process.cwd()+"/",''),
                                                        myparent.range[0],
                                                        myparent.range[1],
                                                       // myparent.expression.arguments[0].params[0].name,
                                                        ast.body[0].expression.arguments[0].name]
                                                    );
                                                }

                                                    var entry ={};
                                                    entry.pos = myparent.expression.arguments[0].range[0];
                                                    entry.end = myparent.expression.arguments[0].range[1];
                                                    entry.text = args[0];
                                                    entry.file = aaa[1];
                                                    entry.argf = "";
                                                    entry.tablename = tablename;
                                                    entry.adaptedsqlInvocation = adaptedsqlInvocation11;
                                                    var sqlInvloc = format("{0}:{1}:{2}", [aaa[1].replace(process.cwd()+"/",''),myparent.range[0], myparent.range[1]]);
                                                    J$.mashallingLog.sqlInvocationsloc.push(sqlInvloc);
                                                    // if(J$.mashallingLog.sqlInvocations.length==0)
                                                        J$.mashallingLog.sqlInvocations.push(entry);
                                                    // if(sqlInvocations.length==0)
                                                        sqlInvocations.push(entry);
                                                    console.log("adaptedsqlInvocation11", adaptedsqlInvocation11,myparent.expression.arguments[0].range);
                                            }
                                            break;
                                        }
                                        myparent= myparent.parent;
                                    }
                                }
                      }});

                }
	        }
            return {f: f, base: base, args: args, skip: false};
        };

        this.invokeFun = function (iid, f, base, args, result, isConstructor, isMethod, functionIid, functionSid) {
          var id = J$.getGlobalIID(iid);
            var location = J$.iidToLocation(id);
            var aaa = /\((.+):(.+):(.+):(.+):(.+)\)/g.exec(location);
            var type_val = typeof val;
            if(!aaa[1].includes("node_modules") && aaa !=null && aaa.length == 6){

                        var code = fs.readFileSync(aaa[1]).toString();
                        var escodegen = require('escodegen');
                        var pos = lineColumn(code).toIndex(aaa[2], aaa[3]);
                        var end =  lineColumn(code).toIndex(aaa[4], aaa[5]);
                        var fff = code.slice(pos, end);
            }

            return {result: result};
        };
        // this.literal = function (iid, val, hasGetterSetter) {return {result: val};};
        // this.forinObject = function (iid, val) {return {result: val};};
        // this.declare = function (iid, name, val, isArgument, argumentIndex, isCatchParam) {return {result: val};};
        // this.getFieldPre = function (iid, base, offset, isComputed, isOpAssign, isMethodCall) {return {base: base, offset: offset, skip: false};};
        // this.getField = function (iid, base, offset, val, isComputed, isOpAssign, isMethodCall) {return {result: val};};
        // this.putFieldPre = function (iid, base, offset, val, isComputed, isOpAssign) {return {base: base, offset: offset, val: val, skip: false};};
        // this.putField = function (iid, base, offset, val, isComputed, isOpAssign) {return {result: val};};
        // this.read = function (iid, name, val, isGlobal, isScriptLocal) {return {result: val};};

        this.write = function (iid, name, val, lhs, isGlobal, isScriptLocal) {
            var id = J$.getGlobalIID(iid);
            var location = J$.iidToLocation(id);
            var aaa = /\((.+):(.+):(.+):(.+):(.+)\)/g.exec(location);
            var type_val = typeof val;
            if(!aaa[1].includes("node_modules") && J$.toRollback && aaa !=null && aaa.length == 6  && type_val !=='object' && type_val !=='function' && parseInt(val)){
            if(90000<parseInt(val) && parseInt(val) <99999) {
                    // console.log("process.cwd()",process.cwd())
                  // if(sqlInvocations.uuid<uuid){
                      if(1==1){
                    // if(sqlInvocations.length==0 || (sqlInvocations.length==1 && sqlInvocations.uuid<uuid)){
                        var code = fs.readFileSync(aaa[1]).toString();
                        var escodegen = require('escodegen');
                        var pos = lineColumn(code).toIndex(aaa[2], aaa[3]);
                        var end =  lineColumn(code).toIndex(aaa[4], aaa[5]);
                        var fff = code.slice(pos, end);

                        J$.mashallingLog.entry = {};
                        J$.mashallingLog.entry.filename =aaa[1].replace(process.cwd()+"/",'');
                        J$.mashallingLog.entry.filnenamerange = aaa[1].replace(process.cwd()+"/",'')+":"+pos+":"+end;
                        J$.mashallingLog.entry.range =[pos, end];
                        J$.mashallingLog.entry.value = val-90000;

                        var ast = esprima.parse(code,{ loc: true, range: true });
                        var identifers = [];
                        var entryfact = "";
                        estraverse.traverse(ast, {
                            enter: function (node, parent) {
                                node.parent = parent;
                            if (node.type =="Identifier" && node.range[0]>=pos && node.range[1]<=end){
                                // var findingnode=parent;
                                if(parent.parent && parent.parent.type=="VariableDeclarator" && parent.parent.id.name==name) {
                                    // console.log("EEEE", escodegen.generate(parent.parent), parent.parent.type, parent.parent.id.range);
                                    entryfact= format("fp.fact(ref(BitVecVal(hashVar[\"{0}\"][\"bin\"],var),BitVecVal({1},val)))",[J$.mashallingLog.entry.filename+":"+parent.parent.id.range[0]+":"+parent.parent.id.range[1],polycrc.crc24(JSON.stringify(val-90000))]);
                                    J$.mashallingLog.entry.value_sid =polycrc.crc24(JSON.stringify(val-90000));
                                }
                            }
                        }});

                        J$.mashallingLog.entry.rwfacts = entryfact;
                        console.log(colors.magenta("Entry Point Identifed"+"  WRITE(|"+val+"|)"+entryfact));
                        console.log(colors.green(J$.mashallingLog));
                        // console.log(uuid, "<-ENTRYPOINT:",pos,end, fff,  name,location, "  WRITE(|"+val+"|)",J$.mashallingLog);
                        // entryPointMap[parseInt(val)] = location; //keep latest WRITE
                    }

                   if(!entryPointMap[parseInt(val)]){
                        entryPointMap[parseInt(val)] = location;
                    }//first visit
                // }

                    uuid++;
                        // logEvent("<-ENTRYPOINT:", name,"  WRITE(|"+val+"|)", location);
                }else if(entryPointMap[parseInt(val)+9000]==location){
                         return {entry:location};
                         J$.entryCursor = uuid;
                         // console.log(uuid, "@@@@@@@@@            >>> ENTRYPOINT:", name,location,"  WRITE(|", entryPointMap[location],"->",val,"|)");
                }else{
                          //  console.log(colors.grey(uuid, "@@@@@@@@@            >>> ENTRYPOINT:", name,location,"  WRITE(|", entryPointMap[location],"->",val,"|)"));
                }
            }//entry points


            else if(!aaa[1].includes("node_modules")&& J$.toRollback && aaa !=null && aaa.length == 6 && type_val ==='object' &&(hasEqualinParam(val)!=undefined)){

                    // console.log(colors.magenta("Object Entry Point Identifed"));

                        var code = fs.readFileSync(aaa[1]).toString();
                        var escodegen = require('escodegen');
                        var pos = lineColumn(code).toIndex(aaa[2], aaa[3]);
                        var end =  lineColumn(code).toIndex(aaa[4], aaa[5]);
                        var fff = code.slice(pos, end);

                        J$.mashallingLog.entry = {};
                        J$.mashallingLog.entry.filename =aaa[1].replace(process.cwd()+"/",'');
                        J$.mashallingLog.entry.filnenamerange = aaa[1].replace(process.cwd()+"/",'')+":"+pos+":"+end;
                        J$.mashallingLog.entry.range =[pos, end];
                        J$.mashallingLog.entry.value = val;

                        var ast = esprima.parse(code,{ loc: true, range: true });
                        var identifers = [];
                        var entryfact = "";
                        estraverse.traverse(ast, {
                            enter: function (node, parent) {
                                node.parent = parent;
                            if (node.type =="Identifier" && node.range[0]>=pos && node.range[1]<=end){
                                // var findingnode=parent;
                                if(parent.parent && parent.parent.type=="VariableDeclarator" && parent.parent.id.name==name) {
                                    // console.log("EEEE", escodegen.generate(parent.parent), parent.parent.type, parent.parent.id.range);
                                    entryfact= format("fp.fact(ref(BitVecVal(hashVar[\"{0}\"][\"bin\"],var),BitVecVal({1},val)))",[J$.mashallingLog.entry.filename+":"+parent.parent.id.range[0]+":"+parent.parent.id.range[1],polycrc.crc24(JSON.stringify(val))]);
                                    J$.mashallingLog.entry.value_sid =polycrc.crc24(JSON.stringify(val));
                                }
                            }
                        }});

                        J$.mashallingLog.entry.rwfacts = entryfact;
                        console.log(colors.magenta("Object Entry Point Identifed"+"  WRITE(|"+val+"|)"+entryfact));
                        console.log(colors.green(J$.mashallingLog));
                        // console.log(uuid, "<-ENTRYPOINT:",pos,end, fff,  name,location, "  WRITE(|"+val+"|)",J$.mashallingLog);
                        // entryPointMap[parseInt(val)] = location; //keep latest WRITE


            }


             if(!aaa[1].includes("node_modules")&& aaa !=null && aaa.length == 6  && typeof val =="string" && val == "JSRCIInsourcing"){
                 console.log(colors.green(J$.mashallingLog));
                 console.log(colors.magenta("@@@@@@@@@@@@@Starting Insourcing!!!"+constraints_solver(J$.mashallingLog)));

             }
            if(!aaa[1].includes("node_modules")&& aaa !=null && aaa.length == 6  && typeof val =="string" && val == "JSRCIRestore"){
                    //J$.toRollback = true;
                    console.log(colors.magenta("@@@@@@@@@@@@@JSRCIRestore"));

                    try {
                        if (J$.methods.m1 = !undefined) J$.methods.m1.query("SELECT * from recipes", function (error, results, fields) {
                            console.log("######", results);
                        });
                    }catch (e){}
                    for(var key in J$.rollbacks) {
                            //var value = objects[key];
                        try{
                    	console.log("J$.rollbacks."+key+"();");
                        eval("J$.rollbacks."+key+"();");

                        }catch(e){console.error("ERROR	J$.rollbacks."+key+"();");}
                    }

            }
				  //else if(aaa !=null && aaa.length == 6 && type_val ==='object' &&(!aaa[1].includes("node_modules"))){
				//  else if(aaa !=null && aaa.length == 6 && !aaa[1].includes("node_modules") && type_val ==='object' &&(hasEqual(val)!=undefined)){
             else if(!aaa[1].includes("node_modules")&& J$.toRollback && aaa !=null && aaa.length == 6 && type_val ==='object' &&(hasEqual(val)!=undefined)){

                 var code = fs.readFileSync(aaa[1]).toString();
                 var pos = lineColumn(code).toIndex(aaa[2], aaa[3]);
                 var end =  lineColumn(code).toIndex(aaa[4], aaa[5]);
                 var fff = code.slice(pos, end);

                // ;
                 var ast = esprima.parse(code,{ loc: true, range: true });
                 var identifers = [];
                 var newexitfact;

                 var text="";
                if(identifers.length==2){
                   text= format("fp.fact(ref2(BitVecVal(hashVar[\"{0}\"][\"bin\"],var),BitVecVal(hashVar[\"{1}\"],prop),BitVecVal({2},val)))",[identifers[0],identifers[1], polycrc.crc24(JSON.stringify(val))]);
                    // var fact = "fp.fact(ref2(BitVecVal(hashVar[\""+identifers+"\"][\"bin\"],var),BitVecVal(hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:546:552"]["bin"],prop), BitVecVal(1999,val)))

                }
                    J$.currentOutput = val;
                    J$.mashallingLog.exit = {};
                    J$.mashallingLog.exit.filename =aaa[1].replace(process.cwd()+"/",'');
                    J$.mashallingLog.exit.filnenamerange = aaa[1].replace(process.cwd()+"/",'')+":"+pos+":"+end;
                    J$.mashallingLog.exit.range =[pos, end];
                    J$.mashallingLog.exit.val=JSON.stringify(val);

                    var escodegen = require('escodegen');
                    // console.log("fwrwr",escodegen.generate(ast));
                    estraverse.traverse(ast, {
                    enter: function (node, parent) {
                        node.parent = parent;
        // if (node.type == 'FunctionExpression' || node.type == 'FunctionDeclaration')
        //     return estraverse.VisitorOption.Skip;
                    if (node.type =="Identifier" && node.range[0]>=pos && node.range[1]<=end){
                        identifers.push(aaa[1].replace(process.cwd()+"/",'')+":"+node.range[0]+":"+node.range[1]);
                        // if(node.parent)
                        // if(parent && parent.parent)
                        // if(parent)
                        console.log("@@@@@@",escodegen.generate(node), escodegen.generate(parent), parent.type);
                        if(parent && parent.type=="VariableDeclarator" && parent.id.name==name) {
                        console.log("OOOOOOEEEE");
                        newexitfact= format("fp.fact(ref(BitVecVal(hashVar[\"{0}\"][\"bin\"],var),BitVecVal({1},val)))",[J$.mashallingLog.exit.filename+":"+parent.id.range[0]+":"+parent.id.range[1],polycrc.crc24(JSON.stringify(val))]);
                        J$.mashallingLog.exit.value_sid =polycrc.crc24(JSON.stringify(val));
                       }

                       else if(parent.parent && parent.parent.type=="VariableDeclarator" && parent.parent.id.name==name) {
                        console.log("OOOOOOEEEE");
                        newexitfact= format("fp.fact(ref(BitVecVal(hashVar[\"{0}\"][\"bin\"],var),BitVecVal({1},val)))",[J$.mashallingLog.exit.filename+":"+parent.parent.id.range[0]+":"+parent.parent.id.range[1],polycrc.crc24(JSON.stringify(val))]);
                        J$.mashallingLog.exit.value_sid =polycrc.crc24(JSON.stringify(val));
                       }
                    }
                }});

                         // J$.mashallingLog.exit.rwfacts=text;
                    J$.mashallingLog.exit.rwfacts = newexitfact;
                 // console.log(text, uuid, "->EXITPOINT:", name, location,fff, lhs, "  WRITE OJB(|", JSON.stringify(val), "|)",typeof val,  hasEqual(val), "ENTRY??   ",J$.mashallingLog);
                 console.log(colors.magenta("Exit Point Identifed"+"  WRITE(|"+JSON.stringify(val)+"|)  "+newexitfact+",,,"+name));
                 console.log(colors.green(J$.mashallingLog));
                //if(IsJsonFormat(val)){

                // console.log(J$.entryCursor, uuid, "->EXITPOINT:", name, location, "  WRITE OJB(|", JSON.stringify(val), "|)",typeof val,  hasEqual(val));
                uuid++;
            /**
                if(!exitPointMap[hasEqual(val)]){

                    exitPointMap[hasEqual(val)] = "->EXITPOINT:", name, location, "  WRITE OJB(|", JSON.stringify(val), "|)",typeof val,  hasEqual(val);
                    console.log(uuid, "->EXITPOINT:", name, location, "  WRITE OJB(|", JSON.stringify(val), "|)",typeof val,  hasEqual(val));
                    uuid++;
                }else if(J$.toRollback){
                // console.log(colors.gray("       ->EXITPOINT:"), colors.red(name), colors.gray(location, "  WRITE OJB(|", JSON.stringify(val), "|)",typeof val,  hasEqual(val)));
                }

             **/
             }


            return {result: val, test:"abcd"};
        };



        this.functionEnter = function (iid, f, dis, args) {

            var id = J$.getGlobalIID(iid);
            var location = J$.iidToLocation(id);
            var aaa = /\((.+):(.+):(.+):(.+):(.+)\)/g.exec(location);

        if(aaa !=null && aaa.length == 6 &&(!aaa[1].includes("node_modules"))){
		//if(aaa !=null && aaa.length == 6){






		    // if(args[0].)
		    // console.log("ffffffffffunctionEnter", pos, end, fff, args[0]);
            var util = require('util');
            if(args[0] && util.inspect(args[0]).includes("JSRCIStr")){
                var code = fs.readFileSync(aaa[1]).toString();
                var pos = lineColumn(code).toIndex(aaa[2], aaa[3]);
                var end = lineColumn(code).toIndex(aaa[4], aaa[5]);
                var fff = code.slice(lineColumn(code).toIndex(aaa[2], aaa[3]), lineColumn(code).toIndex(aaa[4], aaa[5]));
                // var ast_program1 = esprima.parse(fff,{ loc: true, range: true });
                var ast_program = esprima.parse(code,{ loc: true, range: true });
                 console.log("JSRCIStrJSRCIStrJSRCIStrJSRCIStrJSRCIStr   ");

                 estraverse.traverse(ast_program, {
                enter: function (node, parent) {
                    node.parent = parent;
                if (node.type =="BlockStatement" && node.range[0]>=pos && node.range[1]<=end && node.body && !J$.mashallingLog.entry){
                    // var findingnode=parent;


                        // pos = ast_program1.body[0].body.body[0].range[0];
                        // end = ast_program1.body[0].body.body[0].range[1];
                        J$.mashallingLog.entry = {};
                        J$.mashallingLog.entry.filename =aaa[1].replace(process.cwd()+"/",'');
                        J$.mashallingLog.entry.filnenamerange = aaa[1].replace(process.cwd()+"/",'')+":"+node.body[0].range[0]+":"+node.body[0].range[1];
                        J$.mashallingLog.entry.range =[node.body[0].range[0], node.body[0].range[1]];
                        J$.mashallingLog.entry.value = "JSRCIStr";

                        entryfact= format("fp.fact(refs(BitVecVal(hashVar[\"{0}\"][\"bin\"],lineNum),BitVecVal({1},val)))",[J$.mashallingLog.entry.filename+":"+node.body[0].range[0]+":"+node.body[0].range[1],polycrc.crc24("JSRCIStr")]);
                        J$.mashallingLog.entry.value_sid =polycrc.crc24("JSRCIStr");
                        J$.mashallingLog.entry.rwfacts = entryfact;
                        console.log(colors.magenta("Entry Point Identified"+"  WRITE(|JSRCIStr|)"+entryfact));
                        console.log("JSRCIStr111   ", escodegen.generate(node.body[0]), J$.mashallingLog.entry.filnenamerange);

                }
                }});



            // parseObjectProperties(args[0], function(prop) {
            //   console.log("argggggg     ", prop);
            //   if(prop==)
            // });
                // console.log(args[0]);
                // Object.entries(args[0]).forEach(([key, value]) => {
                //         if(typeof value ==='string')
                //             console.log(`2222222         ${key} ${value}`);
                //     });
            }else if(args[0] && util.inspect(args[0]).includes("JSRCIInsourcing")){

                   console.log(colors.green(J$.mashallingLog));
                 console.log(colors.magenta("!!@@@@@@@@@@@@@Starting Insourcing!!!"+constraints_solver(J$.mashallingLog)));

            }
		for(var e in J$.mashallingLog.sqlInvocations){
		    console.log("J$.mashallingLog.sqlInvocations[e]",J$.mashallingLog.sqlInvocations[e]);
		    // 494 582 :::  561 576
		    if(args && J$.mashallingLog.sqlInvocations[e].pos == pos && J$.mashallingLog.sqlInvocations[e].end == end && args[0] && args[0].length>0){
		        console.log("!@!@!@!@!!!!!!!3333333		functionEnter() arg	", fff, args[0]);
            // }
			// if(args && args[1]  && sqlInvocations[e].pos < pos && sqlInvocations[e].end > end && sqlInvocations[e].text.includes("from")) {var JSRCI_var;NUM = NUM+100;

                /**
                console.log("!!!!!!!!!!!1		functionEnter() arg	",J$.mashallingLog.sqlInvocations[e], J$.mashallingLog.sqlInvocations,
				JSON.parse(JSON.stringify(args[0]),"\n" ,J$.mashallingLog.sqlInvocations[e]),
				// J$.methods.f689, "J$.sqlInvocationsMap",
				// J$.sqlInvocationsMap,
				"J$$$$$$$$$$",//J$.snapshots[0],//Object.getOwnPropertyNames(J$),
				'\n', J$.mashallingLog.sqlInvocations[e].text, J$.mashallingLog.sqlInvocations[e].sqlargvar
				//,J$.rollbacks
				);
                **/
				// J$.toRollback = true;
				// try {
                //     if (J$.methods.m1 = !undefined) J$.methods.m1.query("SELECT * from recipes", function (error, results, fields) {
                //         console.log("######", results)
                //     });
                // }catch (e){}
				// for(var key in J$.rollbacks) {
    			// 		var value = objects[key];
					// try{
				//	console.log("J$.rollbacks."+key+"();");
				// 	eval("J$.rollbacks."+key+"();");
                //
				// 	}catch(e){console.error("ERROR	J$.rollbacks."+key+"();");}
				// }

			//	J$.methods.f689('SELECT * FROM `recipes`','',function (error, results, fields) {console.log("####",results);});
			//	console.log(J$.methods.f689.toString());
				//J$.rollbacks.f137({aaaa:2141241, afsafsaf:1231313123213});
				//J$.rollbacks.f137();
				//aabbba(3333,{aaaa:898989898});
		        // logEvent(sqlInvocations[e].text);
				// logEvent(JSON.stringify(args[0]));
				// logEvent(sqlInvocations[e].sqlvar);
				// console.log("var result=alasql("+sqlInvocations[e].sqlargvar[0]+");");
				// logEvent("var result=alasql("+sqlInvocations[e].sqlargvar[0]+");");
				// console.log("");
				try{
                    var csvData = parse(JSON.parse(JSON.stringify(args[0]).replace(null, "\"null\"")));
                    var dataarr = csvData.split("\n");

                    console.log("^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^alasql(CREATE TABLE "+J$.mashallingLog.sqlInvocations[e].tablename+");");
                    var sqlstmt = format("sqlstmts.append(\"alasql(CREATE TABLE {0});\")",[J$.mashallingLog.sqlInvocations[e].tablename]);
                    // sqlstmt = sqlstmt.replace(/\n/g,"\\n").replace(/"/g, '\\"')+"\"");
//
                    J$.mashallingLog.sqls.push(sqlstmt);

                    for (var i =0; i< dataarr.length; i++){
                        if(i==0){
                            // console.log("alasql(INSERT ("+dataarr[i]+")  INTO "+J$.mashallingLog.sqlInvocations[e].tablename+" ("+dataarr[0]+"));");
                            // logEvent("alasql(CREATE TABLE "+sqlInvocations[e].tablename+");");
                        }else{
                               // var sqlstmt1 = format("sqltmts.append(\"alasql(CREATE TABLE {0});\")",[J$.mashallingLog.sqlInvocations[e].tablename]);
                               var sqlstmt1 = format("sqlstmts.append(\"alasql(INSERT ({0})  INTO {1} ({2}));\")",[dataarr[i].replace(/\n/g,"\\n").replace(/"/g, '\\"'), J$.mashallingLog.sqlInvocations[e].tablename, dataarr[0].replace(/\n/g,"\\n").replace(/"/g, '\\"')]);
                               // sqlstmt1 = sqlstmt1.replace(/\n/g,"\\n").replace(/"/g, '\\"')+"\"");
                               console.log(sqlstmt1);
                               // console.log("alasql(INSERT ("+dataarr[i]+")  INTO "+J$.mashallingLog.sqlInvocations[e].tablename+" ("+dataarr[0]+"));");
                               J$.mashallingLog.sqls.push(sqlstmt1);
                               // J$.mashallingLog.sqls.push("alasql(INSERT ("+dataarr[i]+")  INTO "+J$.mashallingLog.sqlInvocations[e].tablename+" ("+dataarr[0]+"));");
                            // logEvent("alasql(INSERT ("+dataarr[i]+") INTO ("+dataarr[0]+"));");
                        }
                    }
				}catch(e){
					console.log(e);
				}
				//remove it
				// sqlInvocations.splice(e, 1);
			}
				
		}

	}

        };

        this._return = function (iid, val) {return {result: val};};
        this._throw = function (iid, val) {return {result: val};};
        this._with = function (iid, val) {return {result: val};};
        this.functionExit = function (iid, returnVal, wrappedExceptionVal) {return {returnVal: returnVal, wrappedExceptionVal: wrappedExceptionVal, isBacktrack: false};};
        this.scriptEnter = function (iid, instrumentedFileName, originalFileName) {};
        this.scriptExit = function (iid, wrappedExceptionVal) {return {wrappedExceptionVal: wrappedExceptionVal, isBacktrack: false};};
        this.binaryPre = function (iid, op, left, right, isOpAssign, isSwitchCaseComparison, isComputed) {return {op: op, left: left, right: right, skip: false};};
        this.binary = function (iid, op, left, right, result, isOpAssign, isSwitchCaseComparison, isComputed) {return {result: result};};
        this.unaryPre = function (iid, op, left) {return {op: op, left: left, skip: false};};
        this.unary = function (iid, op, left, result) {return {result: result};};
        this.conditional = function (iid, result) {return {result: result};};
        this.instrumentCodePre = function (iid, code, isDirect) {return {code: code, skip: false};};
        this.instrumentCode = function (iid, newCode, newAst, isDirect) {return {result: newCode};};
        this.endExpression = function (iid) {};
        this.endExecution = function () {console.log("endExecution");};
        this.runInstrumentedFunctionBody = function (iid, f, functionIid, functionSid) {return false;};

        this.onReady = function (cb) {
            console.log("this.onReady");
            cb();
            J$.toRollback = true;
        };
    }
    sandbox.analysis = new MyAnalysis();
})(J$);



