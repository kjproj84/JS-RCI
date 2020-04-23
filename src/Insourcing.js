var fs = require('fs');
var ts = require('typescript/lib/typescriptServices');
var randomstring = require("randomstring");

var polycrc = require('polycrc');
var path  = require('path');
var fs1 = require('fs-extra');

var esprima = require('esprima');
var escodegen = require('escodegen');
var estraverse = require('estraverse');


var script = 'python2.7 results/result_datalog.py '
const resolveFrom = require('resolve-from');
var path = require('path');

var rStr_id = 0;
var randtring =["dVXRLg","5sDz7z","dVXRLg","maDMlz"];
var format = require("string-template");

function getExport(fileName, field){
    var code = fs.readFileSync("results/"+fileName).toString();
    var ast = esprima.parse(code,{ loc: true, range: true });
    var hash1=null;
    var aaa ="";
        estraverse.traverse(ast, {
            enter: function (node, parent) {
                node.parent = parent;

                if(node.type == 'AssignmentExpression' && node.left.object.name=="exports" && node.left.property.name==field){
		            // var aaa = fileName+":"+node.loc.start.line;
                    aaa = fileName+":"+node.parent.range[0]+":"+node.parent.range[1];
		            return aaa;
	            }
            }
        });
    return aaa;
}

var AAAA    = '';

var depFiles = [], depOriginalFiles=[];
function analyzeCode(fileName,dr,uid) {
    depOriginalFiles.push(fileName);
    var code = fs.readFileSync('results/'+fileName).toString();
    var ast = esprima.parse(code,{ loc: true, range: true });
    estraverse.traverse(ast, {
            enter: function (node, parent) {
                node.parent = parent;
                if(node.type == 'MemberExpression' && node.object.callee  &&node.object.callee.name=="require"){
	                    var arg = node.object.arguments[0];
                        if(arg){

                            var property = node.property.name;
                            var argR = node.object.arguments[0].value;
                            var rr = resolveFrom(dr, argR);
                            var newid = randomstring.generate(6);
                            newid = randtring[rStr_id];
                            rStr_id++;

                            var hash1;
                            var hashVarNameFact,hashVarCodeFact;

                            var b = node.parent.parent.range[0];
                            var e = node.parent.parent.range[1];
                            var orgarg = code.slice(arg.range[0],arg.range[1]);
                            if(fileName!="AAAA.js") {
                                hash1 = newid+".js"+":"+b+":"+e;
                                code = code.slice(0, arg.range[0]) + "\'./" + newid + "\'" + code.slice(arg.range[1], code.length);
                            }else{//keep filename and locs for mapping facts from jalangi2
                                hash1 = orig_filename+":"+b+":"+e;
                                var newidrequire= code.slice(b, e).replace(orgarg,"\'"+"./"+newid+"\'");
                                hashVarNameFact= format("hashVar[\"{0}\"][\"name\"]=\"{1}\";",[hash1, newidrequire]);
                                AAAA+=hashVarNameFact+'\n';
                                hashVarCodeFact= format("code[hashVar[\"{0}\"][\"bin\"]]=\"{1}\";",[hash1, newidrequire]);
                                AAAA+=hashVarCodeFact+'\n';

                            }
                             var myfd    = fs.openSync("results/"+fileName, 'w+');
                             fs.writeSync(myfd, code+'\n');
                             var newfileName="results/"+newid+".js";
                             fileMap[newid+".js"] = path.resolve(rr).replace(process.cwd()+"/",'');
                             var pp = path.resolve(rr);
                             fs1.copySync(path.resolve(rr), newfileName);
                             var hash2= getExport(newid+".js",property);//parse again to get updated range
                           if(hash2!=null){
                               var h1 = format("hashVar[\"{0}\"][\"bin\"]",[hash1]);
                               var h2 = format("hashVar[\"{0}\"][\"bin\"]",[hash2]);
                               var fact= format('fp.fact(datadep(BitVecVal({0},lineNum),BitVecVal({1},lineNum)))',[h2,h1]);
                               AAAA+=fact+'\n';
                              if(!depFiles.includes(newid+".js")){
                                  depFiles.push(newfileName);
                              }
                           }

                               var dir1 = path.dirname(pp);

                               analyzeCode(newid+".js", dir1,uid);
                            }
                }
            }
    });
}
const exec = require('child_process').exec;

var stage2 = require('./stage2');
var cfgRelated = require('./cfg');

var fileMap ={};
var orig_filename = "";
var boundToExtractFunction=0;
function insourcing(param){
  	var fileName = param.exit.filename;
	depFiles.push(fileName);
	orig_filename = fileName;
	var uid     = 'AAAA';
	var uidline_output = polycrc.crc24("AAAA.js:4");
	fileMap["AAAA.js"] = fileName;
	var code = fs.readFileSync(fileName).toString();
	var dir =path.dirname(fileName);
	var uidfilename = uid+".js";
	fs1.copySync(fileName, "results/"+uidfilename);
    analyzeCode(uidfilename,dir,uid);
    var pyfd    = fs.openSync('./results/result_datalog.py', 'w+');
    var jsprogrammodel = fs.readFileSync('src/z3_rules/jsprogrammodel.py').toString()+'\n';
    fs.writeSync(pyfd, jsprogrammodel+'\n');
    var hashcnt =0;
    for (i = 0; i< depFiles.length; i++) {
      var jscode = fs.readFileSync(depFiles[i]).toString();
      var cfg = cfgRelated.makeCFG(jscode);
      cfgRelated.buildDominatorTrees(cfg, true);
      var result = stage2.phase(cfg,0,depFiles[i].replace("results/",""), jscode,param.sqlInvocationsloc);
      if(i==0) {
          boundToExtractFunction = result.myhashVarCnt;
      }
      fs.writeSync(pyfd, result.toPy+'\n');

   }
    AAAA+= "boundToExtractFunction = "+(boundToExtractFunction-1)+";"+'\n';
    AAAA+= param.entry.rwfacts +'\n';
    AAAA+= param.exit.rwfacts +'\n';
    for(var p=0; p< param.sqlInvocations.length; p++){
        AAAA+="#sql adapted"+'\n';
        AAAA+= param.sqlInvocations[p].adaptedsqlInvocation+'\n';
    }
        AAAA+="#sql statements"+'\n';
    for(var q=0; q< param.sqls.length; q++){
        AAAA+= param.sqls[q]+'\n';
    }//sqls
    AAAA+="value_sid_unmarshal="+param.entry.value_sid+'\n';
    fs.writeSync(pyfd, AAAA+'\n');

    var functiongen = fs.readFileSync('src/z3_rules/functiongen.py').toString()+'\n';
    functiongen= functiongen.replace(/18888/g, param.entry.value_sid);
    functiongen= functiongen.replace(/19999/g, param.exit.value_sid);
    fs.writeSync(pyfd, functiongen+'\n');


    var yourscript = exec(script,
            (error, stdout, stderr) => {
                console.log(`${stdout}`);
                console.log(`${stderr}`);
                if (error !== null) {
                    console.log(`exec error: ${error}`);
                }
    });


	return "Insourcing!!!"+", started from  "+fileName;
}

function testing(namefile){
          var jscode = fs.readFileSync(namefile).toString();
      var cfg = cfgRelated.makeCFG(jscode);
      cfgRelated.buildDominatorTrees(cfg, true);
      var result = stage2.phase(cfg,0,namefile.replace("results/",""));
}

module.exports = insourcing;
// module.testing = testing;
// exports.like = like;
