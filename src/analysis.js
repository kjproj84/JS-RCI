var fs = require('fs');
var ts = require('typescript/lib/typescriptServices');
var randomstring = require("randomstring");

var polycrc = require('polycrc');
var path  = require('path');
var fs1 = require('fs-extra');
var fileName = '../findAllProperties/property-service.js';
var esprima = require('esprima');
var escodegen = require('escodegen');
var estraverse = require('estraverse');
var myLines = require('fs').readFileSync(process.argv[2]).toString().match(/^.+$/gm);
//console.log(myLines);
var script = 'python2.7 z3_result.py '


function hashCode(s) {
    for(var i = 0, h = 0; i < s.length; i++)
        h = Math.imul(31, h) + s.charCodeAt(i) | 0;
    return h;
}
var pointlist=[];
for(var i=0; i<myLines.length;i++){
  console.log(myLines[i]);
  var pm ={id:'',pointType:'',variable:'',file:'',line:''};
  // [ 'ekaDIrW',
  // 'exit',
  // 'PROPERTIES',
  // '../findAllProperties/property-service.js',
  // '4' ]
  var params=myLines[i].split(' ');
  pm.id=params[0];pm.pointType=params[1];pm.variable=params[2];pm.file=params[3];pm.line=params[4];
  pointlist.push(pm);
  // console.log(pm,params);
  fileName = pm.file;

  //return;
}
if(pointlist.length==1 && pointlist[0].pointType=='exit'){
  var exit = pointlist[0];
  fileName = exit.file;
  script = script + " "+exit.variable+":"+exit.line+" "+exit.id;
  console.log(script);
  // return;
}

if(pointlist.length==2 && pointlist[0].pointType=='entry' && pointlist[1].pointType=='exit'
   && pointlist[0].file==pointlist[1].file
){
  var entry = pointlist[0];
  var exit = pointlist[1];
  fileName = exit.file;
  script = script + entry.variable+":"+entry.line +" "+exit.variable+":"+exit.line+" "+exit.id;
  // console.log(script);
  // return;
}


var polycrc = require('polycrc');
var uidline_output='';
uidline_output = polycrc.crc24("AAAA.js:4")
// console.log("uidline_output", uidline_output);
var component = null;
var uid     = 'AAAA';
var pyfd    = fs.openSync('./'+uid, 'w+');
var AAAA    = '';

function traverse(node, func) {
    func(node);//1
    for (var key in node) { //2
        if (node.hasOwnProperty(key)) { //3
            var child = node[key];
            if (typeof child === 'object' && child !== null) { //4

                if (Array.isArray(child)) {
                    child.forEach(function(node) { //5
                        traverse(node, func);
                    });
                } else {
                    traverse(child, func); //6
                }
            }
        }
    }
}

var uidfilename = uid+".js";
fs1.copySync(fileName, uidfilename);

var path = require('path');
var dir =path.dirname(fileName);

//var code = fs.readFileSync(uidfilename).toString();

const resolveFrom = require('resolve-from');
//var ustr  = "broker-service.js:"+pos.start_line+":"+pos.start_offset;
//var hash1 = polycrc.crc24(ustr).toString(10);


function getExport(fileName, field){
    var code = fs.readFileSync(fileName).toString();
    var ast = esprima.parse(code,{ loc: true, range: true });
    var hash1=null;
    traverse(ast, function(node) {
        if(node.type == 'AssignmentExpression' && node.left.object.name=="exports" && node.left.property.name==field){
		var aaa = fileName+":"+node.loc.start.line;
  		hash1 = polycrc.crc24(aaa).toString(10);
		// console.log("AAAA",field," ",hash1, aaa);
	}
    });
    return hash1;
}

function analyzeCode(fileName,dr) {

    //console.log(fileName);
    var code = fs.readFileSync(fileName).toString();
    var ast = esprima.parse(code,{ loc: true, range: true });
    var isUpdate = false;
    var sct = 'sc:'+fileName;
    var sss=fs.readFileSync('./'+uid).toString();
    if(!sss.includes(sct)){
      fs.writeSync(pyfd, 'sc:'+fileName+'\n');
      AAAA= '\n'+AAAA+'sc:'+fileName+'\n';
    }
    // fs.writeSync(pyfd, 'sc:'+fileName+'\n');

    traverse(ast, function(node) {
//	console.log(node);
        //locating annoated statement and updating it.
        //if(node.type == 'ExpressionStatement'){
    if(node.type == 'MemberExpression' && node.object.callee  &&node.object.callee.name=="require"){
        //if(node.type == 'AssignmentExpression' && node.object && node.object.callee && node.object.callee.name=="require"){
       //argument of require
	  var arg = node.object.arguments[0];
		if(arg){
		   // console.log(node.property.name);
		   var property = node.property.name;
		   // console.log(arg.raw, arg.range[0], arg.range[1]);
		   var argR = node.object.arguments[0].value;
		   var rr = resolveFrom(dr, argR);
		   // console.log(rr);
		   //if has .. require .. then..
		   var newid = randomstring.generate(6);
		   code=code.slice(0,arg.range[0])+"\'./"+newid+"\'"+code.slice(arg.range[1],code.length);
		   isUpdate = true;
//		   console.log(code);
          var myfd    = fs.openSync(fileName, 'w+');
          // fs.writeFileSync(fileName, code);
          fs.writeSync(myfd, code+'\n');
    		   // fs.writeFile(fileName, code, (err) => {
    		   // if (err) throw err;
    		   // console.log('not updated!');
    		   // });

		   var newfileName=newid+".js";
		   var aaa = fileName+":"+node.loc.start.line;
  		 var hash1 = polycrc.crc24(aaa).toString(10);
       var pp = path.resolve(rr);
       fs1.copySync(path.resolve(rr), newfileName);
	     var hash2= getExport(newfileName,property);
            console.log("getExport", newfileName, property);
       if(hash2!=null){
		     //copy to working directory and find the line# of exports
  		   // console.log(fileName,newfileName, hash1, hash2);
  		  var fact = 'fp.fact(datadep(BitVecVal('+hash2+',lineNum),BitVecVal('+hash1+',lineNum)))';
          var sss=fs.readFileSync('./'+uid).toString();
          var sct = 'sc:'+newfileName;
          var fact_ = 'fact:'+fact+'\n';
          var req_ = 'req:requires['+hash2+']='+'\''+newfileName+'\'';
         if(!sss.includes(sct)){
           fs.writeSync(pyfd, 'sc:'+newfileName+'\n');
	         AAAA='\n'+AAAA+'sc:'+newfileName+'\n';
         }
         if(!sss.includes(fact_)){
           fs.writeSync(pyfd, 'fact:'+fact+'\n');
	         AAAA='\n'+AAAA+'fact:'+fact+'\n';
         }

         if(!sss.includes(req_)){
           fs.writeSync(pyfd, req_+'\n');
	          AAAA='\n'+AAAA+req_+'\n';

         }
         // console.log(fact);
       }

       var dir1 = path.dirname(pp);
		   // console.log("DRDR",dr);
		   // console.log("DIR", dir1, "@@",newfileName);
	     analyzeCode(newfileName, dir1);
		}
          	///console.log(escodegen.generate(node), "   ",node.loc.start.line,"  " ,code.slice(node.range[0],node.range[1]));

        }
    });



}

//copy and project all related scripts and images files
//adding fact for require & export for node.js



analyzeCode(uidfilename,dir);

// console.log("AAAA"+AAAA);



var fs = require('fs');

var esprima = require('esprima');
var colors = require('colors');
var ast = require('./js_wala/common/lib/ast');
var stage1 = require('./stage1');
var stage1_keepline = require('./stage1_keepline');

var stage2 = require('./stage2');
var stage2_keepline = require('./norm_lines');

//var stage2 = require('./stage2');
var cfgRelated = require('./cfg');
var path = require('path');
var pathJSdep =  require.resolve('./stage1');
pathJSdep = path.dirname(pathJSdep);
var fileName = process.argv[2];
// console.log(fileName);
var code = AAAA;
// console.log(code);

var re = /sc:(.+)/g

//console.log(code.match(re));
//var annotations = code.match(re);
var scriptFiles = code.match(re);
if(scriptFiles==null){
  // console.log("no script file is found in  ");
  return;
}else{
  // fs.writeSync(pyfd, content+'\n');
  var pyfd    = fs.openSync('./z3_result.py', 'w+');
  var program = fs.readFileSync(pathJSdep+'/../../z3py_rules/program.py').toString()+'\n';
  fs.writeSync(pyfd, program+'\n');
  // console.log(colors.green(program));
  // console.log(scriptFiles);
  var hashcnt =0;
  for (i = 0; i < scriptFiles.length; i++) {
    var re1 = /sc:(.+)/
    var aaa=scriptFiles[i].match(re1);
    var filename = aaa[1];
    // console.log(filename);


    var code = fs.readFileSync(filename).toString();

    // run stage1 and make normalized code
    var normalized = stage1.phase0(code);
    var normalized_keepline = stage1_keepline.phase0(code);
    var escodegen = require('escodegen');
    // console.log(colors.blue(normalized));

    // var input = esprima.parse(normalized, {loc: true, range:true});
    // buid CFG using JS_WALA
    var cfg = cfgRelated.makeCFG(normalized);
    // build dominator tree using JS_WALA
    cfgRelated.buildDominatorTrees(cfg, true);
    // Print all facts by traversing CFG
    var result = stage2.phase(cfg,hashcnt,filename);
    // console.log(colors.blue(hashcnt));
    // console.log(colors.green(result.toPy));
    fs.writeSync(pyfd, result.toPy+'\n');
    cfg = cfgRelated.makeCFG(normalized_keepline);
    cfgRelated.buildDominatorTrees(cfg, true);
    result = stage2_keepline.phase(cfg,0,filename);
    // console.log("@@result"+result.toPy);
    // console.log(result.toPy.green);
    fs.writeSync(pyfd, result.toPy+'\n');
    hashcnt = result.hashVarCnt;

   }

   var reFact     = /fact:(.+)/g;
   code = AAAA;
   var factRequires  = code.match(reFact);
   // console.log("factRequires",factRequires);
   if(factRequires!=null){
      // console.log("@@",factRequires);
      for (i = 0; i < factRequires.length; i++) {
        var re1 = /fact:(.+)/
        var aaa=factRequires[i].match(re1);
        var factr = aaa[1];
        // console.log("@@",factr);
        fs.writeSync(pyfd, factr+'\n');
      }
   }

   var reRequire     = /req:(.+)/g;
   code = AAAA;
   factRequires  = code.match(reRequire);
   // console.log("Requires[..]",factRequires);
   if(factRequires!=null){
      // console.log("@@",factRequires);
      for (i = 0; i < factRequires.length; i++) {
        var re1 = /req:(.+)/
        var aaa=factRequires[i].match(re1);
        var factr = aaa[1];
        // console.log("@@",factr);
        fs.writeSync(pyfd, factr+'\n');
      }
   }
  var component_gen = fs.readFileSync(pathJSdep+'/../../z3py_rules/component_gen.py').toString()+'\n';
  fs.writeSync(pyfd, component_gen+'\n');

}


const exec = require('child_process').exec;




var yourscript = exec(script,
        (error, stdout, stderr) => {
            console.log(`${stdout}`);
            console.log(`${stderr}`);
            if (error !== null) {
                console.log(`exec error: ${error}`);
            }
        });
