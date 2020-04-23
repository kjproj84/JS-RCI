var falafel = require('falafel');
var fs = require('fs');
var ast = require('./js_wala/common/lib/ast.js');
var sets = require('./js_wala/common/lib/sets.js');
var scope = require('./js_wala/normalizer/lib/scope.js');

function iterCFG(nd, f) {
    function rec(nd) {
        iterCFG(nd, f);
    }

    if (!nd) {
        return;
    }
    var pos  = ast.getPosition(nd);
    // console.log("sstart_line"+pos.start_line);
    switch(nd.type) {
        case 'Program':
            f(nd.attr.fakeRoot);
            nd.body.forEach(rec);
            break;
        // MODIFIED by CH
        case 'FunctionExpression':
        case 'FunctionDeclaration':
            f(nd);
            f(nd.attr.fakeRoot);
            rec(nd.body);
            break;

        case 'EmptyStatement':
        case 'DebuggerStatement':
        case 'VariableDeclaration':
        case 'ReturnStatement':
        case 'BreakStatement':
        case 'ThrowStatement':
            f(nd);
            break;

        case 'ExpressionStatement':
            f(nd);
            //console.log("nd.arguments ExpressionStatement", nd.source());
            for(var i in nd.expression.arguments){
                if( nd.expression.arguments[i].type==='FunctionExpression') {
                    // console.log("nd.arguments ", nd.expression.arguments[i].body);
                    rec(nd.expression.arguments[i].body);
                }
            }

            break;

        case 'IfStatement':
            f(nd);
            f(nd.test);
            rec(nd.consequent);
            rec(nd.alternate);
            break;

        case 'WhileStatement':
            f(nd);
            f(nd.test);
            rec(nd.body);
            break;
        case 'ForInStatement':
            f(nd);
            rec(nd.body);
            break;

        case 'LabeledStatement':
            f(nd);
            rec(nd.body);
            break;

        case 'TryStatement':
            f(nd);
            rec(nd.block);
            if (nd.handlers && nd.handlers[0]) {
                rec(nd.handlers[0].body);
            }
            if (nd.finalizer) {
                rec(nd.finalizer);
            }
            break;

        case 'BlockStatement':
            for (var i=0; i<nd.body.length; ++i) {
                rec(nd.body[i]);
            }
            break;
        case 'BinaryExpression':
            f(nd);
            break;

        case 'ForStatement':
            f(nd);
            f(nd.init);
            f(nd.test);
            f(nd.update);
            // console.log("FFFFForrr"+getMyHashFromNd(nd));
            // console.log("FFFFForrrinit"+getMyHashFromNd(nd.init));
            var forcd=[];
            forcd.push(getMyHashFromNd(nd.init));
            forcd.push(getMyHashFromNd(nd.test));
            forcd.push(getMyHashFromNd(nd.update));
            ast.setAttribute(nd, 'forcd', forcd);
            // console.log("EEEEE"+ast.getAttribute(nd,'forcd'));
            rec(nd.body);
            break;
        case 'Identifier':
            f(nd);
            break;
        default:
            console.log(nd);
            throw new Error("unexpected statement of type " + nd.type);
    }
}

/********************************
  Functions for Statement debug
*********************************/
/*
function dumpNode(nd) {
    "use strict";
    if (!nd) {
        return "<null>";
    }
    var pos = ast.getPosition(nd);
    if (nd.type === 'FunctionDeclaration') {
        return nd.type + ": function " + nd.id.source() + " at " + pos.start_line + ':' + pos.end_offset;

    }
    if (nd.type === 'Program') {
        return "[ " + nd.type + " ]";
    }
    if (nd.source === undefined) {
        return nd.type + " at " + pos.start_line + ':' + pos.end_offset;
    } else {
        return nd.type + " : " + nd.source() + " at " + pos.start_line + ':' + pos.end_offset;
    }
}
*/

function dumpNodeHash(nd) {
    "use strict";
    if (!nd) {
        return "<null>";
    }
    var pos = ast.getPosition(nd);
    var hash = ast.getAttribute(nd, 'hash');
    if (nd.type === 'FunctionDeclaration') {
        return hash + " // " + nd.type + ": function " + nd.id.source() + " at " + pos.start_line + ':' + pos.end_offset;

    }
    if (nd.type === 'Program') {
        return "[ " + nd.type + " ]";
    }
    if (nd.source === undefined) {
        return hash + " // " + nd.type + " at " + pos.start_line + ':' + pos.end_offset;
    } else {
        return hash + " // " + nd.type + " : " + nd.source() + " at " + pos.start_line + ':' + pos.end_offset;
    }
}

function dumpHash(nd) {
    "use strict";
    if (!nd) {
        return "<null>";
    }
    var hash = ast.getAttribute(nd, 'hash');
    if (nd.type === 'FunctionDeclaration') {
        return hash;

    }
    if (nd.type === 'Program') {
        return "[ " + nd.type + " ]";
    }
    return hash;
}

var debugStmtMsg = "";
function debugStmtSave(nd)
{
    var ctrlPy="";
    "use strict";
    var succs = ast.getAttribute(nd, 'succ');
    var idom = ast.getAttribute(nd, 'idom');
    var ipdom = ast.getAttribute(nd, 'ipdom');
    var pred = ast.getAttribute(nd, 'pred');
    if(pred && Array.isArray(pred)) {

        debugStmtMsg = debugStmtMsg + "\n---------------------------------------------------------" + pred.length + ", " + pred;
      for (var i = 0; i < pred.length; i++) {
        debugStmtMsg = debugStmtMsg + "\n-@-@-@-"+getMyHashFromNd(pred[i]);
        if(pred[i].type==='Entry'||pred[i].type==='ExpressionStatement'||pred[i].type==='VariableDeclaration'||pred[i].type==='ExpressionStatement'||pred[i].type==='ForStatement'||pred[i].type==='IfStatement'||pred[i].type==='WhileStatement'){
            // ctrlPy=ctrlPy+"\nfp.fact(controldep(BitVecVal(" + getMyHashFromNd(pred[i]) + ",lineNum),BitVecVal(" +getMyHashFromNd(nd)+ ",lineNum)))";

        }
      }
    }
    debugStmtMsg = debugStmtMsg + "\n" + dumpNodeHash(nd)+"     "+getMyHashFromNd(nd)+"\n"+nd.type;
    // if(pred && !Array.isArray(pred) && (pred.type==='Entry'||pred.type==='ExpressionStatement'||pred.type==='VariableDeclaration'||pred.type==='ExpressionStatement'||pred.type==='ForStatement'||pred.type==='IfStatement'||pred.type==='WhileStatement')){
    if(pred && pred.parent && pred && !Array.isArray(pred) && (pred.type==='ExpressionStatement'||pred.type==='VariableDeclaration'||pred.type==='ExpressionStatement'||pred.type==='ForStatement'||pred.type==='IfStatement'||pred.type==='WhileStatement')){

        debugStmtMsg = debugStmtMsg + "::pred:: " + getMyHashFromNd(pred) +"type    "+pred.type+"\n";
        // if(getMyHashFromNd(pred)!=getMyHashFromNd(nd)){
        // ctrlPy=ctrlPy+"\nfp.fact(controldep(BitVecVal(" + getDec(getHashVarEndPos(pred, pred.source())) + ",lineNum),BitVecVal(" +getDec(getHashVarEndPos(nd, nd.source()))+ ",lineNum)))";
        // console.log("ctrl>>>>",nd.source());

//     ctrlPy=ctrlPy+"\nfp.fact(controldep(BitVecVal(" + getMyHashFromNd(pred) + ",lineNum),BitVecVal(" +getMyHashFromNd(nd)+ ",lineNum)))";

	// if(pred.parent && pred.parent.parent) console.log("parent", pred.parent.parent.type);
	if(pred.parent && pred.parent.type ==='Program'){
           // console.log("skipp global conrol flow", pred.source());
	}
	// else if(pred.type == "FunctionDeclartion"){
    //     console.log("skipp global conrol flow of FunctionDeclartion", pred.source());
    // }
   	else{
   	    //okay
    		ctrlPy=ctrlPy+"\nfp.fact(controldep(BitVecVal(" + getDec(getHashVarEndPos(pred, pred.source())) + ",lineNum),BitVecVal(" +getDec(getHashVarEndPos(nd, nd.source()))+ ",lineNum)))";
            var aaaa = "::pred:: " + getMyHashFromNd(pred) +"type    "+pred.type+"      "+ getMyHashFromNd(nd)+"    " +nd.type +"fp.fact(controldep(BitVecVal(" + getDec(getHashVarEndPos(pred, pred.source())) + ",lineNum),BitVecVal(" +getDec(getHashVarEndPos(nd, nd.source()))+ ",lineNum)))";+"\n";
            // if(pred.parent.parent && pred.parent.parent.parent)
            // console.log("aaaa", aaaa, pred.parent.parent.parent.type, "\n");
            // else
            // console.log(aaaa, pred.parent.type, "\n");
	}
        // }
    }
    debugStmtMsg = debugStmtMsg + "\n" + "Pred: " + (pred ? sets.map(pred, dumpHash).join(', '): "none");
    if(succs)
        debugStmtMsg = debugStmtMsg +"\n"+ "::Succ:: "+getMyHashFromNd(succs)+"\n";
    debugStmtMsg = debugStmtMsg + "\n" + "Succ: " + (succs ? sets.map(succs, dumpHash).join(', '): "none");
    debugStmtMsg = debugStmtMsg + "\n" + "IDOM: " + (idom ? dumpHash(idom): "none");
    debugStmtMsg = debugStmtMsg + "\n" + "IPDOM: " + (ipdom ? dumpHash(ipdom): "none");
    // console.log("debugStmtMsg>>", debugStmtMsg)
    // if(!nd && !succs)
    //     ctrlPy = ctrlPy+"\nfp.fact(datadep(BitVecVal(" + getMyHashFromNd(nd) + ",lineNum),BitVecVal(" +getMyHashFromNd(succs)+ ",lineNum)))";

    // return ctrlPy+"\nfp.fact(datadep(BitVecVal(" + getMyHashFromNd(succs) + ",lineNum),BitVecVal(" +getMyHashFromNd(nd)+ ",lineNum)))";
    return ctrlPy;
}

function debugStmtPrint()
{
    "use strict";
    // var fd = fs.openSync('stmtDebug.txt', 'w+');
    // fs.writeSync(fd, debugStmtMsg);
}

function getAbsPos(nd)
{
    "use strict";
    var pos = ast.getPosition(nd);
    if (nd.type === 'Entry') {
        return pos.start_line + ':0';
    }
    // return pos.start_line + ':' + pos.end_offset;
      return pos.start_offset + ':' + pos.end_offset;
}

/***************************
  Inverse immediate post dominate relationship object.
****************************/
var inverseIpdom = {};
var inverseIpdomObj = {
    insert: function (nd) {
        "use strict";
        var ipdom = ast.getAttribute(nd, 'ipdom');
        if (ipdom !== undefined) {
            var ipdomPos = getAbsPos(ipdom);
            var ipdomHash = hashStmtObj.get(ipdomPos);
            var ndPos = getAbsPos(nd);
            var ndHash = hashStmtObj.get(ndPos);
            if(inverseIpdom[ipdomHash] === undefined) {
                inverseIpdom[ipdomHash] = [];
                inverseIpdom[ipdomHash][0] = ndHash;
            } else {
                inverseIpdom[ipdomHash][inverseIpdom[ipdomHash].length] = ndHash;
            }
        }
    },
    get: function (x) {
        "use strict";
        // x is hash value
        // ipostdom(z) = x;
        // returns the array of z
        return inverseIpdom[x];
    }
};

/************************************************
  Hash object for hash value of each statement.
*************************************************/
var hashStmtToNode = {};
var hashStmt    = {};
var hashStmtCnt = 0;
var escodegen = require('escodegen');
var hashStmtObj = {
    check: function (pos) {
        "use strict";
        if (hashStmt[pos] === undefined) {
            return false;
        } else {
            return true;
        }
    },
    insert: function (nd) {
        "use strict";
        var pos = getAbsPos(nd);
        var bin = hashStmtCnt.toString(16);
        while (bin.length !== 4) {
            bin = '0'.concat(bin);
        }
        bin = '#x' + bin;
        //escodegen.generate(codes[hash1]);
        hashStmt[pos] = bin;
      //##  console.log(hashStmt);
        var pos11 = ast.getPosition(nd);
        // pos11.url = "broker-service.js";
        //console.log(escodegen.generate(codesp[pos11]));
        //console.log(codesp[pos11]);
        hashStmtCnt++;
        hashStmtToNode[bin] = nd;
    },
    get: function (pos) {
        "use strict";
        return hashStmt[pos];
    },
    getNode: function (hash) {
        "use strict";
        return hashStmtToNode[hash];
    }
};

function setHashStmt(nd)
{
    "use strict";
    if (nd.type === 'Entry') {
        ast.setAttribute(nd, 'hash', "#xffffffff");
        // ast.setAttribute(nd, 'myhash', "0000000");
        return;
    }
    var absPos = getAbsPos(nd);
    var hasVal;
    if (hashStmtObj.check(absPos)) {
        hasVal = hashStmtObj.get(absPos);
        // throw new Error("Conflict Position!");
    } else {
        hashStmtObj.insert(nd);
        hasVal = hashStmtObj.get(absPos);
        ast.setAttribute(nd, 'hash', hasVal);
        // ast.setAttribute(nd, 'myhash', getMyHashFromNd(nd));
    }
}

/************************************************
  Hash object for hash value of variables.
*************************************************/
var hashVarToName = {};
var myhashVarToName = {};
var hashVar = {};
var myhashVar = {};
var hashVarCnt = 0;
var myhashVarCnt = 1000;



/**
var hashVarObj = {
    check: function (name) {
        "use strict";
        if (hashVar[name] === undefined) {
            return false;
        } else {
            return true;
        }
    },
    insert: function (name) {

        "use strict";
        var bin = myhashVarCnt.toString(16);
        while (bin.length !== 4) {
            bin = '0'.concat(bin);
        }
        bin = '#x' + bin;
        hashVar[name] = bin;
        //myhashVar[posStr] = {name:name, bin:bin};
        myhashVarCnt++;
        //myhashVarToName[myhashVarCnt] = {name:name, pos:posStr};
   },

    insertPoS: function (posStr, name,isProp) {
        "use strict";
        var bin = myhashVarCnt.toString(16);
        while (bin.length !== 4) {
            bin = '0'.concat(bin);
        }
        bin = '#x' + bin;
        // if(hashVar[name] !== undefined){
        //     console.log("^^^^^^^^duplicate!");
        // }
	if(!isProp){
        	hashVar[name] = bin;
        	myhashVar[posStr] = {name:name, bin:bin};
        	myhashVarCnt++;
        	myhashVarToName[myhashVarCnt] = {name:name, pos:posStr};

	}else{
        ///	hashVar[name] = bin;
        	myhashVar[posStr] = {name:name, bin:bin};
        	myhashVarCnt++;
        	myhashVarToName[myhashVarCnt] = {name:name, pos:posStr};
	}
    },

    get: function (name) {
        "use strict";
        return hashVar[name];
    },

    myGet: function (name) {
        "use strict";
        return parseInt(hashVar[name].substring(2),16);
    },

    getName: function (hash) {
        "use strict";
        return hashVarToName[hash];
    }
};
**/

var hashVarObj = {
    check: function (name) {
        "use strict";
        if (hashVar[name] === undefined) {
            return false;
        } else {
            return true;
        }
    },
    insert: function (name) {

        "use strict";
        var bin = myhashVarCnt.toString(16);
        while (bin.length !== 4) {
            bin = '0'.concat(bin);
        }
        bin = '#x' + bin;
        hashVar[name] = bin;
        //myhashVar[posStr] = {name:name, bin:bin};
        myhashVarCnt++;
        //myhashVarToName[myhashVarCnt] = {name:name, pos:posStr}; 
   },

    insertPoS: function (posStr, name, isDelcaration, declaredBin) {
        "use strict";
        var bin = myhashVarCnt.toString(16);
        while (bin.length !== 4) {
            bin = '0'.concat(bin);
        }
        bin = '#x' + bin;
        // if(hashVar[name] !== undefined){
        //     console.log("^^^^^^^^duplicate!");
        // }
	if(!isDelcaration){
        	hashVar[name] = bin;
        	myhashVar[posStr] = {name:name, bin:declaredBin};
        	// myhashVarCnt++;
        	myhashVarToName[myhashVarCnt] = {name:name, pos:posStr};

	}else{
            hashVar[name] = bin;
        	myhashVar[posStr] = {name:name, bin:bin};
        	myhashVarCnt++;
        	myhashVarToName[myhashVarCnt] = {name:name, pos:posStr};
	}
    },

    get: function (name) {
        "use strict";
        return hashVar[name];
    },

    myGet: function (name) {
        "use strict";
        return parseInt(hashVar[name].substring(2),16);
    },

    getName: function (hash) {
        "use strict";
        return hashVarToName[hash];
    }
};

function getHashVar(name)
{
    "use strict";
    var hash;
    if (!hashVarObj.check(name) && name.includes("tempVal") || name.includes("tempHash")) {
        hashVarObj.insert(name);
    }
    hash = hashVarObj.get(name);
    return hash;
}

function isPropertyIden(node){
    if(node.parent && node.parent.property){
     if(node.start == node.parent.property.start && node.end ==node.parent.property.end && node.parent.computed==false) return true;
    // console.log(name, node.start, node.end, node.parent.property.start, node.parent.property.end);
    }
return false;
}


function getHashVarEndPos(node,_name)
{
    var name = _name;
    if(node.source && node.source()){
        name = node.source();
    }
    //console.log(isPropertyIden(node), name);
    // if(node.type)
        // console.log("__________nodenode",node.type,node.source());
    var posStr ="";
    if(typeof node === 'string' || node instanceof String) {
        // console.log("____stringnode", node);
       posStr = node;
    } else{
        posStr = toPoSStr(file, ast.getPosition(node).start_offset, ast.getPosition(node).end_offset);
    }
    "use strict";
    var hash;

    //if created, then return
    if(myhashVar[posStr]!==undefined){
		return myhashVar[posStr].bin;
    }

    if(node.type=="Identifier"){
        var id = scope_ctx.identify(ast.getPosition(node).start_offset);
        if(id && id.declaration) {
            var declaration = scope_ctx.identify(ast.getPosition(node).start_offset).declaration;
            var identifier = scope_ctx.identify(ast.getPosition(node).start_offset).identifier;
              // console.log("decldecl_info", declaration, identifier);
            if(declaration.range[0] == identifier.range[0] &&  declaration.range[1] == identifier.range[1]) {
                // console.log("decldecl_itself", declaration, identifier);
                hashVarObj.insertPoS(posStr, name, true);
            }else{
                var posdecl = toPoSStr(file, declaration.range[0], declaration.range[1]);
                // console.log("decldecl_refer", declaration, identifier,posdecl, myhashVar[posdecl].bin);
                if(myhashVar[posdecl] && myhashVar[posdecl].bin)
                hashVarObj.insertPoS(posStr, name, false, myhashVar[posdecl].bin);
                else{
                 hashVarObj.insertPoS(posStr, name, true);
                }
            }
        }else{
            // console.log("decldecl__nono",posStr, node.source());
            // console.log("decldecl__nono",posStr, node.source());
            // console.log("decldecl__nono",posStr, node.source());
            hashVarObj.insertPoS(posStr, node.source(), true);
        }

    }else{
       hashVarObj.insertPoS(posStr, name, true);
    }

    return myhashVar[posStr].bin;

    /**
    if (isPropertyIden(node)&& myhashVar[posStr]===undefined){
        hashVarObj.insertPoS(posStr, name, true);
        hash = myhashVar[posStr].bin;
	    console.log("@@@@@ppp", hash, name);
        return hash;
    }
    if (isPropertyIden(node)&& myhashVar[posStr]!==undefined){
        hash = myhashVar[posStr].bin;
	console.log("@@@@@ppp define", hash,name);
        return hash;
    }

    if (!hashVarObj.check(name) &&  myhashVar[posStr]===undefined) {
        hashVarObj.insertPoS(posStr, name, false);
        hash = myhashVar[posStr].bin;
        return hash;

    }
        if(myhashVar[posStr]!==undefined)
        //hash = hashVar[name];
	hash = myhashVar[posStr].bin;
	else
	// hash = myhashVar[posStr].bin;
        hash = hashVar[name];
        return hash;
        **/
}

function getHashVarEndPos2(node,name)
{   
    //console.log(isPropertyIden(node), name);
    //console.log("$$$$$$$$$$$\n",hashVar);
    var posStr ="";
    if(typeof node === 'string' || node instanceof String) {
        // console.log("####\n", node);
       posStr = node;
    } else{

        posStr = toPoSStr(file, ast.getPosition(node).start_offset, ast.getPosition(node).end_offset);
    }
    "use strict";
    var hash;
    //if propery then create

    if(myhashVar[posStr]!==undefined){
		return myhashVar[posStr].bin;
    }

    if (isPropertyIden(node)&& myhashVar[posStr]===undefined){
        hashVarObj.insertPoS(posStr, name, true);
        hash = myhashVar[posStr].bin;
	// console.log("@@@@@ppp", hash, name);
        return hash;

    }
/**
    if (isPropertyIden(node)&& myhashVar[posStr]!==undefined){
        hash = myhashVar[posStr].bin;
	console.log("@@@@@ppp define", hash,name);
        return hash;
    }
**/
    if (!hashVarObj.check(name) &&  myhashVar[posStr]===undefined) {
        hashVarObj.insertPoS(posStr, name, false);
        hash = myhashVar[posStr].bin;
        return hash;

    }
        if(myhashVar[posStr]!==undefined)
        //hash = hashVar[name];
	hash = myhashVar[posStr].bin;
	else
	// hash = myhashVar[posStr].bin;
        hash = hashVar[name];
        return hash;
}


function getMyHashVar(name)
{
    "use strict";
    var hash;
    if (!hashVarObj.check(name)) {
        hashVarObj.insert(name);
    }
    hash = hashVarObj.get(name);
    return hash;
}

/*************************************************
    Functions for printing flow and stmt facts
**************************************************/
/*
var flowFacts = "";
function printFlow(nd)
{
    "use strict";
    if (nd.type === 'FunctionDeclaration') {
        return;
    }
    var succs = ast.getAttribute(nd, 'succ');
    var parentHash = ast.getAttribute(nd, 'hash');
    var childHash;
    var temp;
    //console.log(nd);
    if (succs.length === undefined) {
        temp = skipFunctionDeclaration(succs);
        childHash = ast.getAttribute(temp, 'hash');
        if (childHash !== undefined) {
            //console.log("(rule (flow " + parentHash + " " + childHash +" ))");
            flowFacts = flowFacts + "\n" + "(rule (flow " + parentHash + " " + childHash +" ))";
        }
    } else {
        for (var i=0; i<succs.length; i++) {
            temp = skipFunctionDeclaration(succs[i]);
            childHash = ast.getAttribute(temp, 'hash');
            if (childHash !== undefined) {
                //console.log("(rule (flow " + parentHash + " " + childHash +" ))");
                flowFacts = flowFacts + "\n" + "(rule (flow " + parentHash + " " + childHash +" ))";
            }
        }
    }
}
*/


/*************************************************
    Functions for reading general rules
     and making smt2 file to be queried.
**************************************************/
function printHashVarAll(start)
{
    "use strict";
    var debugMsg = "";
    var mydebug = "";
    // var toArray = "hashVar = {};\n";
    var toArray = "";
    for (var i in hashVar) {
        debugMsg = debugMsg + "\n" + hashVar[i] + ":" + i;
    }
    // var fd = fs.openSync('hashVarDebug.txt', 'w+');

    // fs.writeSync(fd, debugMsg);

    // for (i = start; i < hashVar.length; i++) {
    for (var i in hashVar) {
        // if(i>=start){
        mydebug = mydebug + "\n" + getDec(hashVar[i]) + ":" + i;
        // toArray = toArray + "\n"+"hashVar[\""+i+"\"]="+getDec(hashVar[i])+";";



        // }
    }

    Object.keys(myhashVar).forEach(function(key) {
        // console.log(key, myhashVar[key]);
	if(myhashVar[key].name)    
     toArray = toArray + "\n"+"hashVar[\""+key+"\"]={\"bin\":"+getDec(myhashVar[key].bin)+", \"name\":\""+myhashVar[key].name.replace(/\n/g,"\\n").replace(/"/g, '\\"')+"\"};";
    });

    // var fd = fs.openSync('MyhashVarDebug.txt', 'w+');

    // console.log(toArray);
    // fs.writeSync(fd, mydebug);
    // smt2FileWritePy(toArray);
    return toArray;

}
var smt2fd;
var pyfd;
var file;
function smt2FileWrite(content)
{
    "use strict";
    // fs.writeSync(smt2fd, content+'\n');
}
var toPy;
function smt2FileWritePy(content)
{
    "use strict";
    // fs.writeSync(pyfd, content+'\n');
    // toPy = content+'\n';

}

var numCons = 0;

function consFileWrite()
{
    "use strict";
    // var fd2 = fs.openSync('numConstraints.txt', 'w+');
    // fs.writeSync(fd2, numCons);
    // fs.closeSync(fd2);
}

function makeGeneralRule()
{
    "use strict";
    //var buffer = fs.readFileSync('../z3_rules/general_rule_z3.smt2').toString();
    var pathJSdep =  require.resolve('./stage1');
    var path  = require('path');
    pathJSdep = path.dirname(pathJSdep);
    //var buffer = fs.readFileSync('./z3_rules/general_rule_z3.smt2').toString();
   // console.log(buffer);
   //  smt2fd = fs.openSync('./z3_result.smt2', 'w+');

    // pyfd = fs.openSync('./z3_result0.py', 'w+');
    //smt2FileWrite(buffer);
}

function addQuery()
{
    "use strict";
    //var buffer = fs.readFileSync('../z3_rules/query_z3.smt2').toString();
    //smt2FileWrite(buffer);

}

/***************************
  Main Traverse
  1. Set Hash value for each statement.
  2. Save inverse immediate post dominate relationship.
  3. Build control dependency construction.
****************************/
var polycrc = require('polycrc');



function getMyHashFromNd(nd){
    if (!nd) {
        return 99999;
    }
  var pos  = ast.getPosition(nd);
  // console.log("getPosition"+file);
  // var ustr  = "broker-service.js:"+pos.start_line+":"+pos.start_offset;
  // var ustr  = file+":"+pos.start_line+":"+pos.end_offset;
  var ustr  = file+":"+pos.start_offset+":"+pos.end_offset;
  // console.log("ustr"+ustr);
  // console.log("&&"+ustr);
  var hash1 = polycrc.crc24(ustr).toString(10);
  //console.log("getMyHashFromNd"+ustr);
  return hash1;
}

function printStmt(nd)
{
    "use strict";
    var hash = ast.getAttribute(nd, 'hash');
    var funcRange;
    if (nd.type === 'FunctionDeclaration') {
        funcRange = "O_" + nd.parent.funcRange;
    } else {
        funcRange = "O_" + nd.funcRange;
    }

    // var fact = "fp.fact(Stmt(BitVecVal("+hash1+",lineNum),BitVecVal("+polycrc.crc24(funcRange).toString(10)+",obj)))";
    // console.log(fact);
    // has is line ..
    // console.log("(rule (Stmt " + hash + " " + funcRange + " ))"+hash1+" func  "+funcRange);


}

function toPoSStr(file, start, end){
    return file+":"+start+":"+end;
}

function printStmtPy(nd)
{
    "use strict";
    // console.log("%%%%%"+nd.source());
    // var hash = ast.getAttribute(nd, 'hash');
    // getMyHashFromNd(nd)
    var funcRange;
    if (nd.type === 'FunctionDeclaration') {
        funcRange = "O_" + nd.parent.funcRange;
    } else {
        funcRange = "O_" + nd.funcRange;
    }

    // var fact = "fp.fact(Stmt(BitVecVal("+hash1+",lineNum),BitVecVal("+polycrc.crc24(funcRange).toString(10)+",obj)))";
    // console.log(fact);
    // has is line ..
    // console.log("(rule (Stmt " + hash + " " + funcRange + " ))"+hash1+" func  "+funcRange);

    return "fp.fact(Stmt(BitVecVal("+getHashVarEndPos(nd,nd.source())+",lineNum),BitVecVal("+getDec(getHashVarEndPos(funcRange, funcRange))+",obj)))";

    // return "fp.fact(Stmt(BitVecVal("+getMyHashFromNd(nd)+",lineNum),BitVecVal("+getDec(getHashVar(funcRange))+",obj)))";
    // return "";
}

function updateSt(origin, add)
{
    "use strict";
    var rtSt = origin;
    if (add === undefined) {
        return rtSt;
    }
    if (add.length !== 0) {
        if (rtSt.length === 0) {
            rtSt = add;
        } else {
            rtSt = origin + "\n" + add;
        }
    }
    return rtSt;
}


function myupdateSt(origin, add)
{
    "use strict";
    var rtSt = origin;

    if (add === undefined) {
        return rtSt;
    }
  //  if(rtSt.indexOf(add)==-1) return rtSt;
    if (add.length !== 0) {
        if (rtSt.length === 0) {
            rtSt = add;
        } else {
            rtSt = origin + "\n" + add;
        }
    }
    return rtSt;
}


function getZ3Num(n)
{
    "use strict";
    var bin = n.toString(16);
    while (bin.length !== 4) {
        bin = '0'.concat(bin);
    }
    bin = '#x' + bin;
    return bin;
}

var nativeCallList = ['require','confirm', 'alert', 'console.log', 'indexOf', 'toString', 'Math.pow', 'Math.cos', 'Math.sin', 'Math.sqrt'];
function checkNativeCalls(nd)
{
    "use strict";
    var callee = nd.callee;
    var src;
    src = callee.source();
    if (nativeCallList.indexOf(src) !== -1) {
        return true;
    }
    if (callee.type === 'MemberExpression') {
        src = callee.property.source();
        if (nativeCallList.indexOf(src) !== -1) {
            return true;
        }
    }
    return false;
}

var hashCnt = 0;
// console.log("hashCnt??",hashCnt);
var timer = false;
var DomReadList = ['getAttribute', 'getContext'];
var DomWriteList = ['lineTo', 'closePath', 'fill', 'stroke', 'remove', 'removeClass', 'html', 'addClass', 'setAttribute', 'appendChild', 'removeChild', 'append', 'clearRect'];


//#x0000 -> 0000 -> (decimal)
function getDec(hashVar){
    if(hashVar!=undefined) {
        return parseInt(hashVar.substring(2), 16);
    } else return 0;
}

function simpleStringify (object){
    var simpleObject = {};
    for (var prop in object ){
        if (!object.hasOwnProperty(prop)){
            continue;
        }
        if (typeof(object[prop]) == 'object'){
            continue;
        }
        if (typeof(object[prop]) == 'function'){
            continue;
        }
        simpleObject[prop] = object[prop];
    }
    return JSON.stringify(simpleObject); // returns cleaned up JSON
};
var CircularJSON = require('circular-json');
function checkCallExpression(left, right, hashPos,myHash)
{



    "use strict";
    var rtSt = "", rtDebugSt = "", rtStPy="";
    var callee = right.callee;


   console.log("AAAAAA"+right.source());
    //+"  "+CircularJSON.stringify(right.arguments))
    var o_name;
    var src, varName, name;
    var eventType;
    // console.log("checkCallExpression", left,right.arguments.length)
    if (left !== null && right.arguments.length >0 ) {

      for (var i in right.arguments) {
          var temp = allAssignment(left, right.arguments[i], hashPos,myHash);
          rtSt = updateSt(rtSt, temp.rtSt);
          rtStPy = myupdateSt(rtStPy, temp.rtStPy);
      }
      return {
          "rtSt": rtSt,
          "rtStPy": rtStPy,
          "rtDebugSt": rtDebugSt
      };

    }
    
    if (left !== null && checkNativeCalls(right)) {
        for (var i in right.arguments) {
            var temp = allAssignment(left, right.arguments[i], hashPos,myHash);
            // console.log("myHash1"+myHash);
             rtSt = updateSt(rtSt, temp.rtSt);
    rtStPy = updateSt(rtSt, temp.rtStPy);
            // temp = allAssignmentPy(left, right.arguments[i], hashPos,myHash);
            // rtStPy = myupdateSt(rtStPy, temp);
        }
        return {
            "rtSt": rtSt,
            "rtStPy": rtStPy,
            "rtDebugSt": rtDebugSt
        };
    }

    /**
    if (callee.type === 'MemberExpression' && left !== null && callee.property.source() === 'getElementById') {
        if (right.arguments[0].type === 'Literal') {
            src = right.arguments[0].value;

            o_name = "O_" + src;
            varName = left.source();
            // Dom(name + o_name)
            rtSt = updateSt(rtSt, "(rule (Dom " + getHashVar(src) + " " + getHashVar(o_name) + " ))");
            numCons++;
            rtDebugSt = updateSt(rtDebugSt, "Dom(" + src + " " + o_name + ")");
            // Assign(var name)
            rtSt = updateSt(rtSt, "(rule (Assign " + getHashVar(varName) + " " + getHashVar(src) + " " + hashPos + " ))");

            // console.log("YYYYY"+getDec(getHashVar(varName)));
            var fact      = "fp.fact(Assign(BitVecVal("+getDec(getHashVar(varName))+",var),BitVecVal("+getDec(getHashVar(src))+",obj),,BitVecVal("+myHash+",lineNum)))";
            rtStPy        = myupdateSt(rtStPy, fact);

            numCons++;
            rtDebugSt = updateSt(rtDebugSt, "Assign(" + varName+" "+src+ " " + hashPos + ")");
            return {
                "rtSt": rtSt,
                "rtDebugSt": rtDebugSt,
                "rtStPy": rtStPy
            };

        } else {
            //throw new Error("I have to cover Identifier of Domref");
        }
    }
**/

/**
    // dom install check
    // object.addeventListener
    if (callee.type === 'MemberExpression' && callee.property.source() === 'addEventListener') {
        var object = callee.object.source();
        eventType = right.arguments[0].value;
        var value = right.arguments[1].source();
        rtSt = updateSt(rtSt, '(rule (dom-install ' + getHashVar(object) + ' ' + getHashVar(eventType) + ' ' + getHashVar(value) + ' ' + hashPos + ' ))');
        numCons++;
        rtDebugSt = updateSt(rtDebugSt, '(rule (dom-install  ' + object + ' ' + eventType + ' ' + value + ' ' + hashPos + ' ))');
        // console.log(rtDebugSt);
        return {
            "rtSt": rtSt,
            "rtDebugSt": rtDebugSt
        };
    }
**/
    // dom write check
    var domName;

//res.json(favorites);
    if (callee.type === 'MemberExpression') {
        // src = callee.property.source();
        //    rtStPy = myupdateSt(rtStPy, "fp.fact(Read1(BitVecVal())BitVecVal("+getDec(getHashVarEndPos(left.property, property))+",var))");
        //  rtStPy = myupdateSt(rtStPy, "fp.fact(Read1(BitVecVal())BitVecVal("+callee.property.source()+",var))");
        // console.log("callee.property.source()"+simpleStringify(callee.property));
        // if (DomWriteList.indexOf(src) !== -1) {
        //     domName = callee.object.source();
            // o_name = "O_" + domName;
            // rtSt = updateSt(rtSt, "(rule (DomWrite "+getHashVar(domName)+" "+hashPos+" ))");
            // numCons++;
            // rtDebugSt = updateSt(rtDebugSt, "DomWrite(" + domName + " " + hashPos+ ")");

        // return {
        //     "rtSt": rtSt,
        //     "rtStPy": rtStPy,
        //     "rtDebugSt": rtDebugSt
        // };
    }
/**
    // dom read check
    if (callee.type === 'MemberExpression') {
        src = callee.property.source();
        if (DomReadList.indexOf(src) !== -1) {
            domName = callee.object.source();
            rtSt = updateSt(rtSt, "(rule (DomRead " + getHashVar(domName) + " " + hashPos + " ))");
            numCons++;
            rtDebugSt = updateSt(rtDebugSt, "DomRead(" + domName + hashPos + ")");
            rtSt = updateSt(rtSt, "(rule (Assign "+getHashVar(left.source())+" "+getHashVar(domName)+ " " + hashPos + " ))");
            // console.log("YYYYY"+myHash);
            var fact      = "fp.fact(Assign(BitVecVal("+getDec(getHashVar(left.source()))+",var),BitVecVal("+getDec(getHashVar(domName))+",obj),BitVecVal("+myHash+",lineNum)))";
            rtStPy        = myupdateSt(rtStPy, fact);

            numCons++;
            rtDebugSt = updateSt(rtDebugSt, "Assign(" + left.source() + " " + hashPos + ")");
        }
        return {
            "rtSt": rtSt,
            "rtDebugSt": rtDebugSt,
            "rtStPy": rtStPy
        };
    }
**/
    // TimerInput
    // setInterval(function, time), setTimeout
    // => dom-install (timer_t, timerinput, function, hashPos)
/**
    if (callee.source() === 'setInterval' || callee.source() === 'setTimeout') {
        var eventFunc = "timer_t";
        eventType = "timerinput";
        var func = right.arguments[0].source();
        if (!timer) {
            var dom = "O_timerInput";
            timer = true;
            // Fact: Dom(timerinput O_timerInput)
            rtSt = updateSt(rtSt, "(rule (Dom " + getHashVar(eventFunc) + " " + getHashVar(dom) + " ))");
            numCons++;
            rtDebugSt = updateSt(rtDebugSt, "Dom(timer_t O_timerInput)");
        }
        rtSt = updateSt(rtSt, "(rule (dom-install " + getHashVar(eventFunc) + " " + getHashVar(eventType) + " " + getHashVar(func) + " " + hashPos + " ))");
            numCons++;
        rtDebugSt = updateSt(rtDebugSt, "(rule (dom-install " + eventFunc + " " + eventType + " " + func + " " + hashPos + " ))");
    }
**/
    // Others are just callexpression
    // fact: Actual(i, z, v)
    rtSt = updateSt(rtSt,"(rule (Actual"+hashPos+" #x0000 "+getHashVar(right.callee.source())+" ))");
    // var res = getHashVar(right.callee.source()).split(" ");
    // console.log("res[0]"+res[0]);
    // console.log("res[1]"+res[1]);
    // rtStPy        = myupdateSt(rtStPy, "fp.fact(Actual(BitVecVal("+myHash+",lineNum), BitVecVal("+getDec("#x0000")+",num), BitVecVal("+getDec(getHashVarEndPos(right.callee, right.callee.source()))+",var)))");
    // console.log("(rule (Actual"+hashPos+" #x0000 "+getHashVar(right.callee.source())+" ))");
    // console.log("fp.fact(Actual(BitVecVal("+myHash+",lineNum), BitVecVal("+getDec("#x0000")+",num)), BitVecVal("+getDec(getHashVarEndPos(right.callee, right.callee.source()))+",var)))");
    numCons++;
    rtDebugSt = updateSt(rtDebugSt, "Actual("+hashPos+" #x0000 "+right.callee.source()+")");


    // fp.fact(Store(BitVecVal(28,var),BitVecVal(7,var), BitVecVal(7,prop), BitVecVal(594972,lineNum)))
    // right.callee.object
    // right.callee.property
    var calleeobject = right.callee.object;
    var myarguments  = right.arguments;
    // var aa = true;
    while(calleeobject!== undefined){
        if(calleeobject.callee) {
            myarguments = calleeobject.arguments;
            calleeobject = calleeobject.callee.object;

        }
        else
            break;
    }
    const keyfound = Object.keys(myhashVar).find(key => getDec(myhashVar[key].bin) == myHash);
    console.log("calleeobject.source", calleeobject.source(), keyfound, sqlInvocations);
     // console.log("myarguments", myarguments[0].source());
// donutsRoutes.js:225:324


    // }

     // if(keyfound=="subject_apps/Donuts/routes/donutsRoutes.js:504:593") {
     if(sqlInvocations.includes(keyfound)){//if this is a sql invocation, then migrate it
         rtStPy = myupdateSt(rtStPy, '#transform sql'+ keyfound);
         rtStPy = myupdateSt(rtStPy, "fp.fact(Actual(BitVecVal(" + myHash + ",lineNum), BitVecVal(" + getDec(getZ3Num(0)) + ",num), BitVecVal(" + getDec(getHashVarEndPos(calleeobject, calleeobject.source()))+"00" + ",var)))");
     } else{
         rtStPy = myupdateSt(rtStPy, "fp.fact(Actual(BitVecVal(" + myHash + ",lineNum), BitVecVal(" + getDec(getZ3Num(0)) + ",num), BitVecVal(" + getDec(getHashVarEndPos(calleeobject, calleeobject.source())) + ",var)))");
     }
    // if(calleeobject)
    // if(right.callee && right.callee.object && right.callee.object.callee && right.callee.object.callee.object)
    //     console.log("calleeobject", right.callee.object.callee.object.source());

    if(right.callee.property && right.callee.property.name=="then"){
         // console.log("@@@@@@here?",right.callee.property.source(), right.callee.object.object.source());
    }


    var cnt = 1;
// myarguments
      for (var i in myarguments) {
        var param = myarguments[i];
    // for (var i in right.arguments) {
    //     var param = right.arguments[i];
        // console.log("param.type"+param.type, " ",param.source());
        // if (param.type === 'Literal' || param.type === 'ArrayExpression' || param.type === 'ObjectExpression') {
        if (param.type === 'Literal' || param.type === 'ArrayExpression' || param.type === 'ObjectExpression' ||param.type==='Identifier') {
            o_name = hashCnt + "tempHash";
            name = hashCnt + "tempVal";
            hashCnt++;
            hashVarObj.insert(o_name);
            // Heap
            rtSt          = updateSt(rtSt, "(rule (Heap " + getHashVar(name) + " " + getHashVar(o_name) + " ))");
            // var fact      = "fp.fact(Heap(BitVecVal("+getDec(getHashVarEndPos(name,name))+",var),BitVecVal("+getDec(getHashVarEndPos(o_name,o_name))+",obj)))";
            var fact      = "fp.fact(Heap(BitVecVal("+getDec(getHashVarEndPos(param, param.source()))+",var),BitVecVal("+getDec(getHashVarEndPos(o_name,o_name))+",obj)))";

            rtStPy        = myupdateSt(rtStPy, fact);


            numCons++;
            rtDebugSt = updateSt(rtDebugSt, "Heap(" + name + " " + o_name + ")");
            // Actual
            rtSt = updateSt(rtSt, "(rule (Actual " + hashPos + " " + getZ3Num(cnt) + " " + getHashVar(name) + "))");
            rtStPy        = myupdateSt(rtStPy, "fp.fact(Actual(BitVecVal("+myHash+",lineNum), BitVecVal("+getDec(getZ3Num(cnt))+",num), BitVecVal("+getDec(getHashVarEndPos(param, param.source()))+",var)))");
            numCons++;
            rtDebugSt = updateSt(rtDebugSt, "Actual(" +hashPos+" "+cnt+" "+name+ ")");
        }
        /**
        else {
            var paramHash = getHashVar(param.source());
            rtSt = updateSt(rtSt, "(rule (Actual " + hashPos + " " + getZ3Num(cnt) + " " + paramHash + "))");
            rtStPy        = myupdateSt(rtStPy, "fp.fact(Actual(BitVecVal("+myHash+",lineNum), BitVecVal("+getDec(getZ3Num(cnt))+",num), BitVecVal("+getDec(paramHash)+",var)))");

            numCons++;
            rtDebugSt = updateSt(rtDebugSt, "Actual(" +hashPos+" "+cnt+" "+param.source()+ ")");
        }
         **/
        cnt++;
    }
    if (left !== null) {
        // fact: CallRet(i, v);
        varName = left.source();
        rtDebugSt = updateSt(rtDebugSt, "CallRet(" + hashPos + " " + varName + ")");
        rtSt = updateSt (rtSt, "(rule (CallRet "+hashPos + " " + getHashVar(varName) + " ))");
        rtStPy        = myupdateSt(rtStPy, "fp.fact(CallRet(BitVecVal("+myHash+",lineNum), BitVecVal("+getDec(getHashVar(varName))+",var)))");
        numCons++;
    }
    return {
        "rtSt": rtSt,
        "rtDebugSt": rtDebugSt,
        "rtStPy": rtStPy
    };
}

var eventList = {
     onclick: 'click',
     click: 'click',
     ondrag: 'drag',
     onchange: 'change',
     onmouseover: 'mouseover',
     onmousemove: 'mousemove',
     onmouseout: 'mouseout',
     onmousedown: 'mousedown',
     onmouseup: 'mouseup',
     onkeydown: 'keydown',
     ondblclick: 'dblclick',
     onresize: 'resize'
};
function domInstallCheck(left, right, hashPos)
{
    "use strict";
    var rtSt = "", rtDebugSt = "";
    // object.onclick = function
    if (left.type === 'MemberExpression') {
        if (eventList[left.property.source()] !== undefined) {
            var object = left.object.source();
            var eventType = eventList[left.property.source()];
            rtSt = updateSt(rtSt, "(rule (dom-install " + getHashVar(object)+" "+getHashVar(eventType)+" "+getHashVar(right.source())+" "+hashPos+" ))");
            numCons++;
            rtDebugSt = updateSt(rtDebugSt, "dom-install( " + object+ " " + eventType+" "+right.source()+" "+hashPos+")");

            return {
                "result": true,
                "rtSt": rtSt
            };
        }
    }

    return {
        result: false
    };
}
function normalizeExpression(nd)
{
    "use strict";
    var rtSt = [];
    var temp, i;
    if (nd.type === 'ObjectExpression' || nd.type === 'Identifier' || nd.type === 'Literal' || nd.type === 'MemberExpression' || nd.type === 'CallExpression') {
        rtSt.push(nd);
        return rtSt;
    }
    if (nd.type === "UnaryExpression" || nd.type === "UpdateExpression") {
        rtSt.push(nd.argument);
        return rtSt;
    } else if (nd.type === 'BinaryExpression' || nd.type === 'LogicalExpression') {
        temp = normalizeExpression(nd.left);
        for (i=0; i<temp.length; i++) {
            rtSt.push(temp[i]);
        }
        temp = normalizeExpression(nd.right);
        for (i=0; i<temp.length; i++) {
            rtSt.push(temp[i]);
        }
        return rtSt;
    } else if (nd.type === 'ThisExpression') {
        // do nothing
        return rtSt;
    } else {
        // console.log(nd.source());
        // throw new Error("Another right type??");
    }
}
var nativeList = {
    "Array": true,
    "Object": true
};
function rightSide(left, right, hashPos, myHash)
{
    "use strict";
    var name, o_name;
    var temp;
    var rtSt = "", rtDebugSt = "", rtStPy="";
    // for the right side
    var rightType;
    var rightSt = "";
    var rightStPy = "", rightDebugSt = "";

    if (right.type === 'Identifier') {
        rightType = "one";
        rightSt = getHashVar(right.source());
        rightStPy = getHashVarEndPos(right, right.source());
        rightDebugSt = right.source();
        rtSt = updateSt(rtSt, "(rule (Read1 " + getHashVar(right.source()) + " " + hashPos + "))");
        // var fact      = "fp.fact(Read1(BitVecVal("+getDec(getHashVar(right.source()))+",var),BitVecVal("+myHash+",lineNum)))";
        var fact      = "fp.fact(Read1(BitVecVal("+getDec(getHashVarEndPos(right, right.source()))+",var),BitVecVal("+myHash+",lineNum)))";
        rtStPy        = myupdateSt(rtStPy, fact);
        numCons++;
        rtDebugSt = updateSt(rtDebugSt, "Read1 ( " + right.source() + " " + hashPos + " )");
    } else if (right.type === 'MemberExpression') {

        // others
        rightType = "two";
        while (right.object !== undefined && right.object.type === 'MemberExpression') {
            right = right.object;
        }
        // this property
        if (right.object.source() === "this") {
            right.object.update(right.funcRange);
        }
        if(right.object.callee && right.object.callee.source()=="require"){
          // console.log("property",right.object.parent.property.source());
          // console.log("scriptfile",right.object.arguments[0].source());
          // if(right.object.property){
            // console.log("@@",right.object.property.source());
          // }
        }

        var object = right.object.source();
        var property = right.property.source();
        // console.log("********object",object, property);
        rightSt = updateSt(rightSt, getHashVar(object) + " " + getHashVar(property));
        rightStPy = myupdateSt(rightStPy, getHashVarEndPos(right.object,object) + " " + getHashVarEndPos(right,property, property));
        rightDebugSt = updateSt(rightDebugSt, object + " " + property);
        // console.log("_____@@@@@@@@@@",scope_ctx.identify(ast.getPosition(right.object).start_offset).declaration, ast.getPosition(right.object).end_offset, object, property);
        //  scope_ctx
        var fact1 =  "(rule (Read2 " + getHashVarEndPos(right.object, object) + " " + getHashVarEndPos(right.property, property) + " " + hashPos + " ))";
        rtSt = updateSt(rtSt,fact1);

        // var myHashVar_obj = parseInt(getHashVar(object).substring(2), 16);
        // var myHashVar_pt = parseInt(getHashVar(property).substring(2), 16);

        var fact = "fp.fact(Read2(BitVecVal("+getDec(getHashVarEndPos(right.object, object))+",var), BitVecVal("+getDec(getHashVarEndPos(right.property, property))+",prop), BitVecVal("+myHash+",lineNum)))";
        // fp.fact(Read2(BitVecVal(17,var),BitVecVal(2,prop),BitVecVal(16736239,lineNum)))
        rtStPy = myupdateSt(rtStPy, fact);
        // console.log("hashPos"+fact);
        numCons++;
        rtDebugSt = updateSt(rtDebugSt, "(rule (Read2 " + object + " " + property + " " + hashPos + " ))");

    } else if (right.type === 'ArrayExpression' || right.type === "Literal" || right.type === "ObjectExpression") {
        rightType = "one";
        o_name = hashCnt + "tempHash";
        name = hashCnt + "tempVal";
        hashCnt++;
        // Heap
        rtSt = updateSt(rtSt, "(rule (Heap " + getHashVar(name) + " " + getHashVar(o_name) + " ))");
        var fact      = "fp.fact(Heap(BitVecVal("+getDec(getHashVar(name))+",var),BitVecVal("+getDec(getHashVar(o_name))+",obj)))";
        rtStPy        = myupdateSt(rtStPy, fact);

        numCons++;
        rtDebugSt = updateSt(rtDebugSt, "Heap(" + name + " " + o_name + ")");
        rightSt = updateSt(rightSt, getHashVar(name));
        // rightSt = updateSt(rightSt, getHashVar(name));
        rightStPy = myupdateSt(rightStPy, getHashVarEndPos(name));
        // rightStPy = updateSt(rightStPy, getHashVarEndPos(name));
        rightDebugSt = updateSt(rightDebugSt, name);
    } else if (right.type === 'NewExpression') {
        // console.log("NewExpression      ", right.type)
        rightType = "one";
        // native function check
        if (nativeList[right.callee.source()] === undefined) {
            rightSt = updateSt(rightSt, getHashVar(right.callee.source()));
            rightStPy = updateSt(rightStPy,  getHashVarEndPos(right.callee, right.callee.source()));
            rightDebugSt = updateSt(rightDebugSt, right.callee.source());
            // fact: Actual(i, z, v)
            rtSt = updateSt(rtSt, "(rule (Actual " + hashPos + " #x0000 " + getHashVar(right.callee.source()) + " ))");
            numCons++;
            rtDebugSt = updateSt(rtDebugSt, "Actual(" + hashPos + " #x0000 " + right.callee.source()+")");
            var cnt = 1;
            for (var i in right.arguments) {
                var param = right.arguments[i];
                if (param.type === 'Literal' || param.type === 'ArrayExpression' || param.type === 'ObjectExpression') {
                    o_name = hashCnt + "tempHash";
                    name = hashCnt + "tempVal";
                    hashCnt++;
                    hashVarObj.insert(o_name);
                    rtSt = updateSt(rtSt, "(rule (Heap " + getHashVar(name) + " " + getHashVar(o_name) + " ))");

                    var fact      = "fp.fact(Heap(BitVecVal("+getDec(getHashVar(name))+",var),BitVecVal("+getDec(getHashVar(o_name))+",obj)))";
                    rtStPy        = myupdateSt(rtStPy, fact);


                    numCons++;
                    rtDebugSt = updateSt(rtDebugSt, "Heap(" + name + " " + o_name + ")");
                    rtSt = updateSt(rtSt, "(rule (Actual "+hashPos+" "+getZ3Num(cnt)+" "+getHashVar(name)+" ))");
                    numCons++;
                    rtDebugSt = updateSt(rtDebugSt, "Actual("+hashPos+" "+cnt+" "+name+")");
                } else {
                    var paramHash = getHashVar(param.source());
                    rtSt = updateSt(rtSt, "(rule (Actual "+hashPos+" "+getZ3Num(cnt)+" "+paramHash+" ))");
                    numCons++;
                    rtDebugSt = updateSt(rtDebugSt, "Actual("+hashPos+" "+cnt+" "+param.source()+")");
                }
                cnt++;
            }
            // fact: CallRet(i, v);
            rtDebugSt = updateSt(rtDebugSt, "CallRet(" + hashPos + " " + left.source() + ")");
            rtSt = updateSt(rtSt, "(rule (CallRet "+hashPos+" "+getHashVar(left.source())+" ))");
            numCons++;
        } else {
            o_name = hashCnt + "tempHash";
            name = hashCnt + "tempVal";
            hashCnt++;
            // Heap
            rtSt = updateSt(rtSt, "(rule (Heap " + getHashVar(name) + " " + getHashVar(o_name) + " ))");
            var fact      = "fp.fact(Heap(BitVecVal("+getDec(getHashVar(name))+",var),BitVecVal("+getDec(getHashVar(o_name))+",obj)))";
            rtStPy        = myupdateSt(rtStPy, fact);

            numCons++;
            rtDebugSt = updateSt(rtDebugSt, "Heap(" + name + " " + o_name + ")");
            rightSt = getHashVar(name);
            rightStPy = getHashVarEndPos(name);
            rightDebugSt = name;
        }
    } else if (right.type === 'CallExpression') {
        temp = checkCallExpression(left, right, hashPos,myHash);
        return {
            "type": "call",
            "rtDebugSt": temp.rtDebugSt,
            "rtSt": temp.rtSt,
            "rtStPy": temp.rtStPy,
        };
    } else {
        var ndArr = [];
        ndArr = normalizeExpression(right);
        for (var j=0; j<ndArr.length; j++) {

            // rtSt = updateSt(rtSt, allAssignment(left, ndArr[j], hashPos, myHash));

            temp = allAssignment(left, ndArr[j], hashPos, myHash);
            rtSt = updateSt(rtSt, temp.rtSt);
            rtStPy = myupdateSt(rtStPy, temp.rtStPy);
            // rtStPy = myupdateSt(rtStPy, allAssignmentPy(left, ndArr[j], hashPos, myHash));

            if (ndArr[j].parent.type === "UpdateExpression") {
                temp = allAssignment(ndArr[j], ndArr[j], hashPos);
            }
        }
        if (j === 0) {
            return {
                "type": "nothing"
            };
        }
        return {
            "type": "normalize",
            "rtSt": rtSt,
            "rtStPy": rtStPy
        };
    }

    return {
        "type": rightType,
        "rightSt": rightSt,
        "rightStPy":rightStPy,
        "rightDebugSt": rightDebugSt,
        "rtSt": rtSt,
        "rtStPy": rtStPy,
        "rtDebugSt": rtDebugSt
    };
}
var tempCnt = 0;
var noneCnt = 0;
function allAssignment(left, right, hashPos, myHash)
{

    var abcd = myHash+"";
    "use strict";
    // for the left side
    var leftType, temp;
     var leftSt = "";
    var leftStPy = "";
    var leftDebugSt = "";
    var rtSt = "", rtDebugSt = "", rtStPy="";
    if (left === null) {
        leftType = "one";
        leftSt = updateSt(leftSt, getHashVar("none" + noneCnt));
        leftStPy = myupdateSt(leftStPy, getDec(getHashVar("none" + noneCnt)));

        leftDebugSt = updateSt(leftDebugSt, "none" + noneCnt);
        // console.log("leftStleftSt", leftStPy)
        noneCnt++;
    } else if (left.type === 'Identifier') {
        leftType = "one";
        leftSt = updateSt(leftSt, getHashVar(left.source()));
        leftStPy = updateSt(leftStPy,getDec(getHashVarEndPos(left, left.source())));
        // console.log("leftStleftSt", leftSt, leftStPy)
        leftDebugSt = updateSt(leftDebugSt, left.source());
        // console.log("Write1",left.source());
        // if (left.source().indexOf("tmpv") === -1) {
          //  rtSt = updateSt(rtSt, "(rule (Write1 " + getHashVar(left.source()) + " " + hashPos + "))");

            var myHashVar = getHashVarEndPos(left, left.source());
            var fact = "fp.fact(Write1(BitVecVal("+getDec(myHashVar)+",var),BitVecVal("+myHash+",lineNum)))";
            rtStPy = myupdateSt(rtStPy, fact);


            rtSt = updateSt(rtSt, "(rule (Write1 " + getHashVar(left.source()) + " " + hashPos + "))");
            numCons++;
            rtDebugSt = updateSt(rtDebugSt, "Write1 (" + left.source() + " " + hashPos + ")");
        // }
    } else if (left.type === 'MemberExpression') {
        // dom installation check
        temp = domInstallCheck(left, right, hashPos);
        if (temp.result) {
            return {rtSt:rtSt,rtStPy:rtStPy};
        }
        // others
        leftType = "two";
        while (left.object !== undefined && left.object.type === 'MemberExpression') {

            left = left.object;
        }
        // this property check
        if (left.object.source() === "this") {
            left.object.update(left.funcRange);
        }

        if (left.object.source() === "exports") {
            // console.log("##exports",left.property.source());
        }

        var object = left.object.source();
        var property = left.property.source();
        leftSt = updateSt(leftSt, getHashVar(object) + " " + getHashVar(property));
        // console.log("leftStleftSt",leftSt)
        leftDebugSt = updateSt(leftDebugSt, object + " " + property);
        rtSt = updateSt(rtSt, "(rule (Write2 " + getHashVar(object) + " " + getHashVar(property) + " " + hashPos + " ))");

        var fact      = "fp.fact(Write2(BitVecVal("+getDec(getHashVarEndPos(left.object, object))+",obj),BitVecVal("+getDec(getHashVarEndPos(left.property, property))+",var), BitVecVal("+myHash+",lineNum)))";
        rtStPy        = myupdateSt(rtStPy, fact);

        numCons++;
        rtDebugSt = updateSt(rtDebugSt, "(rule (Write2 " + object + " " + property + " " + hashPos + " ))");
    } else {
        throw new Error("Another left type??");
    }


    // right side
    temp = rightSide(left, right, hashPos,myHash);
    var rightType = temp.type;
    rtSt = updateSt(rtSt, temp.rtSt);
    rtStPy = myupdateSt(rtStPy, temp.rtStPy);
    rtDebugSt = updateSt(rtDebugSt, temp.rtDebugSt);
    var rightSt = temp.rightSt;
    var rightStPy = temp.rightStPy;
    var rightDebugSt = temp.rightDebugSt;
    // console.log("@@@@@TYPE?? "+JSON.stringify(temp));
    // console.log("@@@@@TYPE??111 "+rightSt);
    var ttt = rightStPy;
     // console.log("@@@"+leftType,"ssssss",rightType);
    // return part
    if (rightType === "normalize") {
        // console.log("nnnnnnnnn",rtStPy);
        return {rtSt:rtSt,rtStPy:rtStPy};
    }

    else if (rightType === "call") {
        // do nothing
        // console.log(rtDebugSt);
        return {rtSt:rtSt,rtStPy:rtStPy};
    } else if (rightType === "nothing") {
        return "";
    } else if (leftType === "one" && rightType === "one") {
        rtSt = updateSt(rtSt, "(rule (Assign " + leftSt + " 11" +ttt+"11 " + hashPos + " ))");
//undefined

        var fact      = "fp.fact(Assign(BitVecVal("+leftStPy+",var),BitVecVal("+getDec(ttt)+",obj),BitVecVal("+abcd+",lineNum)))";
        rtStPy        = myupdateSt(rtStPy, fact);
        if(leftStPy+""=="NaN"){
             // console.log(leftSt,"UUUUUUUU"+fact,getDec(leftSt),leftSt);
        }

        numCons++;
        rtDebugSt = updateSt(rtDebugSt, "Assign(" + leftDebugSt + " " + rightDebugSt + " " + hashPos + ")");
    } else if (leftType === "two" && rightType === "one") {
        rtSt = updateSt(rtSt, "(rule (Store " + leftSt + " " + rightSt + " " + hashPos+ " ))");


        // var myHashVar = parseInt(getHashVar(left.source()).substring(2), 16)
        var aa = leftSt.split(" ");
        // console.log("lllleftSt"+leftSt,left.source());
        // console.log("11rightSt"+rightSt, right.source());
        var fact = "fp.fact(Store(BitVecVal("+getDec(aa[0])+",var),BitVecVal("+getDec(aa[1])+",var), BitVecVal("+getDec(rightStPy)+",prop), BitVecVal("+myHash+",lineNum)))";
        rtStPy = myupdateSt(rtStPy, fact);


        numCons++;
        rtDebugSt = updateSt(rtDebugSt, "Store(" + leftDebugSt + " " + rightDebugSt + " " + hashPos + ")");


    } else if (leftType === "one" && rightType === "two") {
        rtSt = updateSt(rtSt, "(rule (Load " + leftSt + " " + rightSt + " " + hashPos + " ))");
        var aa = rightStPy.split(" ");
         // console.log("!!!!!!leftSt"+leftStPy);
         // console.log("!!!!!!rightSt", rightStPy , aa);

              // console.log("lllleftSt"+leftStPy,left.source(), right.source());
        // console.log("11rightSt"+rightSt, right);
        var a1 =  parseInt(getDec(aa[1]));
        var fact      = "fp.fact(Load(BitVecVal("+leftStPy+",var),BitVecVal("+getDec(aa[0])+",var), BitVecVal("+a1+",prop),BitVecVal("+myHash+",lineNum)))";
        rtStPy        = myupdateSt(rtStPy, fact);


        numCons++;
        // console.log("OOOO"+leftSt+"::::"+rightSt+fact);
        rtDebugSt = updateSt(rtDebugSt, "Load(" + leftDebugSt + " " + rightDebugSt + " " + hashPos + ")");
    } else if (leftType === "two" && rightType === "two") {
        var tempN = "ttemp" + tempCnt;
        var hashN = getHashVar(tempN);
        var myHashN = getHashVarEndPos(tempN, tempN);
        tempCnt++;
        rtSt = updateSt(rtSt, "(rule (Load " + hashN + " " + rightSt + " " + hashPos + " ))")
        var aa = rightSt.split(" ");
        var fact      = "fp.fact(Load(BitVecVal("+getDec(myHashN)+",var),BitVecVal("+getDec(aa[0])+",prop), BitVecVal("+getDec(aa[1])+",var),BitVecVal("+myHash+",lineNum)))";
        rtStPy        = myupdateSt(rtStPy, fact);
//        var fact      = "fp.fact(Load(BitVecVal("+getDec(leftSt)+",var),BitVecVal("+getDec(rightSt)+",var),BitVecVal("+myHash+",lineNum)))";
//        rtStPy        = myupdateSt(rtStPy, fact);

        numCons++;
        rtSt = updateSt(rtSt, "(rule (Store " + leftSt + " " + hashN + " " + hashPos + " ))");

        var aa = rightStPy.split(" ");
        // console.log("@leftSt"+leftSt);
        // console.log("@rightSt"+rightSt);
        var fact = "fp.fact(Store(BitVecVal("+getDec(leftSt)+",var),BitVecVal("+getDec(aa[0])+",prop), BitVecVal("+getDec(aa[1])+",var), BitVecVal("+myHash+",lineNum)))";

        rtStPy        = myupdateSt(rtStPy, fact);
        numCons++;
        rtDebugSt = updateSt(rtDebugSt, "(rule (Load " + tempN + " " + rightDebugSt + " " + hashPos + " ))");
        rtDebugSt = updateSt(rtDebugSt, "(rule (Store " + leftDebugSt + " " + tempN + " " + hashPos + " ))");
    } else {
        throw new Error("two two case????");
    }
    // console.log("changed?", rtStPy);
    return {rtSt:rtSt,rtStPy:rtStPy};
}




  var rtStPy = "";
var install = false;
function traverseCFGM(root)
{
    "use strict";
    var rtSt = "",rtStPy="";
    var pos  = ast.getPosition(root);
    // console.log("sstart_line"+pos.start_line);
    iterCFG(root, function(nd) {
        if(nd.source)
        // console.log("@@@@", nd.source())
        // set hash value for statement
        setHashStmt(nd);
        // var rtSt = "",rtStPy="";

        var o_name, my_o_name, o_nameHash, my_o_nameHash;
        var nameHash;
        var paramHash, temp;
        var testFlag = false;
        var cnt;
        // console.log("traverseCFGM "+simpleStringify(nd));
        var myHash = '';

        // console.log("ndndndndndnd   "+ast.getPosition(nd));
        if (nd.type !== 'Entry') {

            if (!install) {
                rtSt = updateSt(rtSt, "(rule (Dom " + getHashVar("document") + " " + getHashVar("doc") + " ))");
                numCons++;
                // console.log("Dom(document doc)");
                install = true;
            }

            if(nd.parent.type ==='Program' && nd.type!=='EmptyStatement'){
                 myHash = getHashVarEndPos(nd, nd.source());
                // console.log("GGGGGGGGGglobal?   ",ast.getPosition(nd).start_offset,", ",ast.getPosition(nd).end_offset, "  ", myHash, "  ",nd.source());
                // rtStPy = myupdateSt(rtStPy, "globals["+myHash+"]=\""+nd.source().replace(/\n/g,"\\n").replace(/"/g, '\\"')+"\"");
            }
            var hashPos = ast.getAttribute(nd, 'hash');
            myHash = getHashVarEndPos(nd, nd.source());
            myHash = getDec(myHash);
            // function declaration
            if (nd.type === 'FunctionDeclaration') {
                testFlag = true;
                o_name = "O_" + nd.id.source();
                o_nameHash = getHashVar(o_name);
                console.log("o_name ",o_name)
                my_o_name = getHashVarEndPos(String(o_name), String(o_name));

                nameHash = getHashVar(nd.id.source());
                my_o_nameHash = getHashVarEndPos(nd.id.source(), nd.id.source());
                // console.log("================================================"+myHash);
                // console.log("functionDeclaration: " + nd.id.source());
                rtSt = updateSt(rtSt, ";;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;");
                rtSt = updateSt(rtSt, ";functionDeclaration: " + nd.id.source().replace(/\n/g,"\\n"));
                // rtStPy = myupdateSt(rtStPy, "#functionDeclaration: "+nd.id.source())
                // Fact: FuncDecl(O_func)
                rtSt = updateSt(rtSt, "(rule (FuncDecl " + nameHash + " " + o_nameHash + " " + hashPos +" ))");
                rtStPy = myupdateSt(rtStPy, "#functionDeclaration: "+nd.id.source().replace(/\n/g,"\\n"));
                // rtStPy = myupdateSt(rtStPy, "code["+myHash+"]=\""+nd.source().replace(/\n/g,"\\n").replace(/"/g, '\\"')+"\"");
                rtStPy = myupdateSt(rtStPy, "code["+myHash+"]=\""+nd.source().replace(/\n/g,"\\n").replace(/[\""]/g, '\\"')+"\"");
                // rtStPy = myupdateSt(rtStPy, "code["+myHash+"]=\""+nd.source().replace(/\n/g,"\\n")+"\"");
                // rtStPy = myupdateSt(rtStPy, "lines["+myHash+"]="+ast.getPosition(nd).start_line);
                // rtStPy = myupdateSt(rtStPy, "ranges["+myHash+"]=["+ast.getPosition(nd).start_line+","+ast.getPosition(nd).end_line+"]");

                // rtStPy = myupdateSt(rtStPy, "globals["+myHash+"]=\""+nd.source().replace(/\n/g,"\\n").replace(/"/g, '\\"')+"\"");

                // rtStPy = myupdateSt(rtStPy, "code["+myHash+"]=\""+nd.source().replace(/"/g, '\\"')+"\"").replace(/\n/g,"\\n");
                numCons++;
                // console.log("@@@@FuncDecl(" + nd.id.source() + " " + o_name + " " + hashPos + ")");
                var fact="fp.fact(FuncDecl(BitVecVal("+getDec(my_o_name)+",var),BitVecVal("+getDec(my_o_nameHash)+",obj),BitVecVal("+myHash+",lineNum)))"
                // console.log("@@@@"+fact);
                rtStPy = myupdateSt(rtStPy, fact);
                // console.log("@@@@"+rtStPy);
                // Fact: Formal(O_func, 1, param1)
                cnt = 1;
                for (var i in nd.params) {
                    paramHash = getHashVar(nd.params[i].source());

                    rtSt = updateSt(rtSt,"(rule (Formal "+o_nameHash+" "+getZ3Num(cnt)+" "+paramHash+" ))");
                    // console.log("Formal(" +o_name+" "+cnt+" "+nd.params[i].source() + ")");
                    paramHash = getHashVarEndPos(nd.params[i], nd.params[i].source());
                    var fact="fp.fact(Formal(BitVecVal("+getDec(my_o_nameHash)+",obj),BitVecVal("+getDec(getHashVarEndPos(nd.params[i], nd.params[i].source()))+",obj),BitVecVal("+getDec(getZ3Num(cnt))+",obj)))"
                    rtStPy = myupdateSt(rtStPy, fact);
                    numCons++;

                    cnt++;
                }
            }

            // "return"
            if (nd.type === 'ReturnStatement' && nd.argument !== null) {
                testFlag = true;
                // console.log("================================================"+myHash);
                // console.log("ReturnStatement: " + nd.source());
                rtSt = updateSt(rtSt, ";;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;");
                rtSt = updateSt(rtSt, ";ReturnStatement: " + nd.source());
                rtStPy = myupdateSt(rtStPy, "#ReturnStatement: "+nd.source());
                // rtStPy = myupdateSt(rtStPy, "code["+myHash+"]=\""+nd.source().replace(/"/g, '\\"')+"\"");
                rtStPy = myupdateSt(rtStPy, "code["+myHash+"]=\""+nd.source().replace(/[\""]/g, '\\"')+"\"");

                // rtStPy = myupdateSt(rtStPy, "lines["+myHash+"]="+ast.getPosition(nd).start_line);
                // rtStPy = myupdateSt(rtStPy, "ranges["+myHash+"]=["+ast.getPosition(nd).start_line+","+ast.getPosition(nd).end_line+"]");

                // Fact: MethodRet(O_func param)
                o_name = "O_" + nd.funcRange;
                o_nameHash = getHashVar(o_name);
                paramHash = getHashVar(nd.argument.source());
                rtSt = updateSt(rtSt, "(rule (MethodRet "+o_nameHash+" " + paramHash + " ))");

                var fact="fp.fact(MethodRet(BitVecVal("+getDec(o_nameHash)+",obj),BitVecVal("+getDec(paramHash)+",var)))"

                rtStPy = myupdateSt(rtStPy, fact);
                numCons++;
                // console.log("MethodRet("+o_name+" "+nd.argument.source()+")");
            }

            // All assignmentExpression
            if (nd.type === 'ExpressionStatement' && nd.expression.type === 'AssignmentExpression') {
                testFlag = true;
                // console.log("================================================"+myHash);
                // rtSt = updateSt(rtSt, ";;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;");

                var exp = nd.expression;
                if (exp.right.type === 'FunctionExpression') {
                    o_name = "O_" + exp.left.source();
                    o_nameHash = getHashVar(o_name);
                    nameHash = getHashVar(exp.left.source());
                    // console.log("functionDeclaration: " + exp.left.source());
                    rtStPy = myupdateSt(rtStPy, "#functionDeclaration: "+ exp.left.source().replace(/\n/g,"\\n").replace(/"/g, '\\"'));
                    rtSt = updateSt(rtSt, ";functionDeclaration: " + exp.left.source().replace(/\n/g,"\\n").replace(/"/g, '\\"'));
                    rtStPy = myupdateSt(rtStPy, "code["+myHash+"]=\""+nd.source().replace(/\n/g,"\\n").replace(/[\""]/g, '\\"')+"\"");
                    // rtStPy = myupdateSt(rtStPy, "lines["+myHash+"]="+ast.getPosition(nd).start_line);
                    // rtStPy = myupdateSt(rtStPy, "ranges["+myHash+"]=["+ast.getPosition(nd).start_line+","+ast.getPosition(nd).end_line+"]");
                    // Fact: FuncDecl(O_func)
                    rtSt = updateSt(rtSt, "(rule (FuncDecl " + nameHash + " " + o_nameHash + " " +hashPos + " ))");





                    rtStPy =
myupdateSt(rtStPy, "fp.fact(FuncDecl(BitVecVal("+getHashVarEndPos(exp.left,exp.left.source())+",var),BitVecVal("+myHash+",obj),BitVecVal("+myHash+",lineNum)))");

                    numCons++;
                    // console.log("FuncDecl(" + exp.left.source() + " " + o_name + " " + hashPos + ")");
                    // Fact: Formal(O_func, 1, param1)
                    cnt = 1;
                    for (var i in exp.right.params) {
                        paramHash = getHashVar(exp.right.params[i].source());
                        rtSt = updateSt(rtSt,"(rule (Formal "+o_nameHash+" "+getZ3Num(cnt)+" "+paramHash+" ))");

                        fact="fp.fact(Formal(BitVecVal("+getHashVarEndPos(o_nameHash,o_nameHash)+",obj), BitVecVal("+getZ3Num(cnt)+",obj), BitVecVal("+myHash+",var)))"

                    rtStPy = myupdateSt(rtStPy, fact);
                        numCons++;
                        // console.log("Formal(" +o_name+" "+cnt+" "+exp.right.params[i].source() + ")");
                        cnt++;
                    }
                }
                // This property
                else if (exp.left.type === 'MemberExpression' && exp.left.object.type === 'ThisExpression') {
                    // console.log("ThisExpression: " + nd.source());
                    rtSt = updateSt(rtSt, ";ThisExpression: " + nd.source());
                    rtStPy = myupdateSt(rtStPy, "#ThisExpression: "+ exp.source());
                    //rtStPy = myupdateSt(rtStPy, "code["+myHash+"]="+nd.source());
                    rtStPy = myupdateSt(rtStPy, "code["+myHash+"]=\""+nd.source().replace(/[\""]/g, '\\"')+"\"");
                    // rtStPy = myupdateSt(rtStPy, "lines["+myHash+"]="+ast.getPosition(nd).start_line);
                    // rtStPy = myupdateSt(rtStPy, "ranges["+myHash+"]=["+ast.getPosition(nd).start_line+","+ast.getPosition(nd).end_line+"]");
                    // console.log(exp.left.type + ", " + exp.right.type);
                    temp = allAssignment(exp.left, exp.right, hashPos,myHash);
                    rtSt = updateSt(rtSt, temp.rtSt);
                    // temp = allAssignmentPy(exp.left, exp.right, hashPos,myHash);
                    rtStPy = myupdateSt(rtStPy, temp.rtStPy);
                } else {
                    // other assignment
                    // console.log("Assignment: " + nd.source().replace(/\n/g,"\\n").replace(/"/g, '\\"'));
                    rtSt = updateSt(rtSt, ";Assignment: " + nd.source().replace(/\n/g,"\\n").replace(/"/g, '\\"'));
                    rtStPy = myupdateSt(rtStPy, "#Assignment: "+ nd.source().replace(/\n/g,"\\n").replace(/"/g, '\\"')+"\"");
                    rtStPy = myupdateSt(rtStPy, "code["+myHash+"]=\""+nd.source().replace(/\n/g,"\\n").replace(/[\""]/g, '\\"')+"\"");
                    // rtStPy = myupdateSt(rtStPy, "lines["+myHash+"]="+ast.getPosition(nd).start_line);
                    // rtStPy = myupdateSt(rtStPy, "ranges["+myHash+"]=["+ast.getPosition(nd).start_line+","+ast.getPosition(nd).end_line+"]");
                    temp = allAssignment(exp.left, exp.right, hashPos,myHash);
                    rtSt = updateSt(rtSt, temp.rtSt);
                    // temp = allAssignmentPy(exp.left, exp.right, hashPos,myHash);
                    rtStPy = myupdateSt(rtStPy, temp.rtStPy);
                }
            }

            // All Variable declaration
            if (nd.type === 'VariableDeclaration') {

                testFlag = true;
                // console.log("================================================"+myHash);
                //console.log("@@@@@VariableDecl: " + nd.source());
                rtSt = updateSt(rtSt, ";;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;");
                rtSt = updateSt(rtSt, ";VariableDecl: " + nd.source().replace(/\n/g,"\\n").replace(/"/g, '\\"'));
                rtStPy = myupdateSt(rtStPy, "#VariableDecl: "+ nd.source().replace(/\n/g,"\\n").replace(/"/g, '\\"'));
                //var code = "code["+myHash+"]="+nd.source()+"\n";
                rtStPy = myupdateSt(rtStPy, "code["+myHash+"]=\""+nd.source().replace(/\n/g,"\\n").replace(/[\""]/g, '\\"')+"\"");
                // rtStPy = myupdateSt(rtStPy, "lines["+myHash+"]="+ast.getPosition(nd).start_line);
                // rtStPy = myupdateSt(rtStPy, "ranges["+myHash+"]=["+ast.getPosition(nd).start_line+","+ast.getPosition(nd).end_line+"]");
                for (var i in nd.declarations) {
                    var dec = nd.declarations[i];
                    if (dec.init !== null) {
                        temp = allAssignment(dec.id, dec.init, hashPos,myHash);
                        // console.log("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@VariableDecl11", nd.source(),temp.rtSt);
                        rtSt = updateSt(rtSt, temp.rtSt);

                        // temp = allAssignmentPy(dec.id, dec.init, hashPos,myHash);
                        rtStPy = myupdateSt(rtStPy, temp.rtStPy);
                        // console.log("#vvvvvvvv###",nd.source(), temp.rtStPy)
                    }
                }
            }

            // All Call expression
            if (nd.type === 'ExpressionStatement' && nd.expression.type === 'CallExpression') {
                testFlag = true;
                // console.log("=111==============================================="+myHash);
                // console.log("CallExpression: " + nd.source()+"   "+simpleStringify(nd.expression));
                rtSt = updateSt(rtSt, ";;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;");
                //rtSt = updateSt(rtSt, ";CallExpression: " + nd.source());
                var stmt1 = fs.readFileSync(process.cwd()+"/"+file).toString().slice(ast.getPosition(nd).start_offset, ast.getPosition(nd).end_offset);
                rtStPy = myupdateSt(rtStPy, "#CallExpression:"+file+":"+ast.getPosition(nd).start_offset+process.cwd());
               // rtStPy = myupdateSt(rtStPy, "code["+myHash+"]=\""+stmt1.replace(/\n/g,"\\n").replace(/[\""]/g, '\\"')+"\"");
                rtStPy = myupdateSt(rtStPy, "code["+myHash+"]=\""+stmt1.replace(/\n/g,"\\n").replace(/[\""]/g, '\\"')+"\"");



                // rtStPy = myupdateSt(rtStPy, "lines["+myHash+"]="+ast.getPosition(nd).start_line);
                // rtStPy = myupdateSt(rtStPy, "ranges["+myHash+"]=["+ast.getPosition(nd).start_line+","+ast.getPosition(nd).end_line+"]");
                temp = checkCallExpression(null, nd.expression, hashPos, myHash);
                // console.log(temp.rtDebugSt);
                rtSt = updateSt(rtSt, temp.rtSt);
                rtStPy = updateSt(rtStPy, temp.rtStPy);
            }

            // update expression1
            if (nd.type === 'UpdateExpression') {
                testFlag = true;
                // console.log("================================================"+myHash);
                // console.log("UpdateExpression: " + nd.source());
                rtSt = updateSt(rtSt, ";;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;");
                rtSt = updateSt(rtSt, ";UpdateExpression: " + nd.source());
                rtStPy = myupdateSt(rtStPy, "#UpdateExpression: "+ nd.source());
                rtStPy = myupdateSt(rtStPy, "code["+myHash+"]=\""+nd.source().replace(/[\""]/g, '\\"')+"\"");
                // rtStPy = myupdateSt(rtStPy, "lines["+myHash+"]="+ast.getPosition(nd).start_line);
                // rtStPy = myupdateSt(rtStPy, "ranges["+myHash+"]=["+ast.getPosition(nd).start_line+","+ast.getPosition(nd).end_line+"]");
                // rtStPy = myupdateSt(rtStPy, "lines["+myHash+"]="+ast.getPosition(nd).start_line);
                temp = allAssignment(nd.argument, nd.argument, hashPos,myHash);
                rtSt = updateSt(rtSt, temp.rtSt);
                // temp = allAssignmentPy(nd.argument, nd.argument, hashPos,myHash);

                rtStPy = myupdateSt(rtStPy, temp.rtStPy);
            }
            // update expression2
            if (nd.type === 'ExpressionStatement' && nd.expression.type === 'UpdateExpression') {
                testFlag = true;
                // console.log("================================================"+myHash);
                // console.log("UpdateExpression: " + nd.source());
                rtSt = updateSt(rtSt, ";;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;");
                rtSt = updateSt(rtSt, ";UpdateExpression: " + nd.source().replace(/\n/g,"\\n").replace(/"/g, '\\"'));
                rtStPy = myupdateSt(rtStPy, "#UpdateExpression: "+ nd.source().replace(/\n/g,"\\n").replace(/[\""]/g, '\\"'));
                rtStPy = myupdateSt(rtStPy, "code["+myHash+"]=\""+nd.source().replace(/[\""]/g, '\\"')+"\"");
                // rtStPy = myupdateSt(rtStPy, "lines["+myHash+"]="+ast.getPosition(nd).start_line);
                // rtStPy = myupdateSt(rtStPy, "ranges["+myHash+"]=["+ast.getPosition(nd).start_line+","+ast.getPosition(nd).end_line+"]");
                temp = allAssignment(nd.expression.argument, nd.expression.argument, hashPos,myHash);
                rtSt = updateSt(rtSt, temp.rtSt);

                // temp = allAssignmentPy(nd.expression.argument, nd.expression.argument, hashPos,myHash);
                rtStPy = myupdateSt(rtStPy, temp.rtStPy);
            }

            // MemberExpression
            if (nd.type === 'MemberExpression') {
                testFlag = true;
                // console.log("================================================"+myHash);
                // console.log("MemberExpression: " + nd.source());
                rtSt = updateSt(rtSt, ";;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;");
                rtSt = updateSt(rtSt, ";MemberExpression: " + nd.source().replace(/\n/g,"\\n").replace(/[\""]/g, '\\"'));
                rtStPy = myupdateSt(rtStPy, "#MemberExpression: "+ nd.source().replace(/\n/g,"\\n").replace(/[\""]/g, '\\"'));
                rtStPy = myupdateSt(rtStPy, "code["+myHash+"]=\""+nd.source().replace(/[\""]/g, '\\"')+"\"");
                // rtStPy = myupdateSt(rtStPy, "lines["+myHash+"]="+ast.getPosition(nd).start_line);
                // rtStPy = myupdateSt(rtStPy, "ranges["+myHash+"]=["+ast.getPosition(nd).start_line+","+ast.getPosition(nd).end_line+"]");
                temp = allAssignment(null, nd, hashPos);
                rtSt = updateSt(rtSt, temp.rtSt);

                // temp = allAssignmentPy(exp.left, exp.right, hashPos,myHash);
                rtStPy = myupdateSt(rtStPy, temp.rtStPy);
            }

            // BinaryExpression & LogicalExpression
            if (nd.type === 'BinaryExpression' || nd.type === 'LogicalExpression' || nd.type === 'Identifier') {
                testFlag = true;
                // console.log("================================================"+myHash);
                // console.log("BBBBBBBBB",nd.type + ": " + nd.source());
                rtSt = updateSt(rtSt, ";;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;");
                rtSt = updateSt(rtSt, ";" + nd.type + ": " + nd.source().replace(/\n/g,"\\n").replace(/[\""]/g, '\\"'));
                rtStPy = myupdateSt(rtStPy, "#"+ nd.type + ": " + nd.source().replace(/\n/g,"\\n").replace(/[\""]/g, '\\"'));
                rtStPy = myupdateSt(rtStPy, "code["+myHash+"]=\""+nd.source().replace(/\n/g,"\\n").replace(/[\""]/g, '\\"')+"\"");
                // rtStPy = myupdateSt(rtStPy, "lines["+myHash+"]="+ast.getPosition(nd).start_line);
                // rtStPy = myupdateSt(rtStPy, "ranges["+myHash+"]=["+ast.getPosition(nd).start_line+","+ast.getPosition(nd).end_line+"]");
                temp = allAssignment(null, nd, hashPos,myHash);
                rtSt = updateSt(rtSt, temp.rtSt);

                //temp = allAssignmentPy(exp.left, exp.right, hashPos,myHash);
                // var mytemp = allAssignmentPy(null, nd, hashPos,myHash);
                rtStPy = myupdateSt(rtStPy, temp.rtStPy);
            }

            // don't have to check if and for
            if (nd.type === 'IfStatement' || nd.type === 'ForStatement'|| nd.type==='WhileStatement' || nd.type==='ForInStatement') {
                testFlag = true;
                rtStPy = myupdateSt(rtStPy, "code["+myHash+"]=\""+nd.source().replace(/\n/g,"\\n").replace(/[\""]/g, '\\"')+"\"");
                // rtStPy = myupdateSt(rtStPy, "lines["+myHash+"]="+ast.getPosition(nd).start_line);
                // rtStPy = myupdateSt(rtStPy, "ranges["+myHash+"]=["+ast.getPosition(nd).start_line+","+ast.getPosition(nd).end_line+"]");
                if(nd.type==='IfStatement'){

                    rtStPy = myupdateSt(rtStPy, "fp.fact(controldep(BitVecVal(" + getDec(getHashVarEndPos(nd.test, nd.test.source())) + ",lineNum),BitVecVal(" +getDec(getHashVarEndPos(nd,nd.source()))+ ",lineNum)))");
                }
                if(nd.type==='ForStatement'){
                     // var forcd = ast.getAttribute(nd, 'forcd');
                    // var forcd=[];
                    // forcd.push(getMyHashFromNd(nd.init));
                    // forcd.push(getMyHashFromNd(nd.test));
                    // forcd.push(getMyHashFromNd(nd.update));
                    rtStPy = myupdateSt(rtStPy, "fp.fact(controldep(BitVecVal(" + getDec(getHashVarEndPos(nd.init,nd.init.source())) + ",lineNum),BitVecVal(" +getDec(getHashVarEndPos(nd,nd.source()))+ ",lineNum)))");
                    rtStPy = myupdateSt(rtStPy, "fp.fact(controldep(BitVecVal(" + getDec(getHashVarEndPos(nd.test,nd.test.source())) + ",lineNum),BitVecVal(" +getDec(getHashVarEndPos(nd,nd.source()))+ ",lineNum)))");
                    rtStPy = myupdateSt(rtStPy, "fp.fact(controldep(BitVecVal(" + getDec(getHashVarEndPos(nd.update,nd.update.source())) + ",lineNum),BitVecVal(" +getDec(getHashVarEndPos(nd,nd.source()))+ ",lineNum)))");


                      // rtStPy = myupdateSt(rtStPy, "fp.fact(controldep(BitVecVal(" + getMyHashFromNd(nd) + ",lineNum),BitVecVal(" +getMyHashFromNd(nd.init)+ ",lineNum)))");
                    // rtStPy = myupdateSt(rtStPy, "fp.fact(controldep(BitVecVal(" + getMyHashFromNd(nd) + ",lineNum),BitVecVal(" +getMyHashFromNd(nd.test)+ ",lineNum)))");
                    // rtStPy = myupdateSt(rtStPy, "fp.fact(controldep(BitVecVal(" + getMyHashFromNd(nd) + ",lineNum),BitVecVal(" +getMyHashFromNd(nd.update)+ ",lineNum)))");
                    // ast.setAttribute(nd, 'forcd', forcd);
            // console.log("EEEEE"+ast.getAttribute(nd,'forcd'));
            //         console.log("RRRRRRRRRRR"+forcd);
                }
            }

            // others for debug purpose
            if (!testFlag) {
                // console.log("===================undetected================");
                // rtStPy = myupdateSt(rtStPy, "code["+myHash+"]=\""+nd.source().replace(/"/g, '\\"')+"\"");
                // rtStPy = myupdateSt(rtStPy, "lines["+myHash+"]="+ast.getPosition(nd).start_line);
                // rtStPy = myupdateSt(rtStPy, "ranges["+myHash+"]=["+ast.getPosition(nd).start_line+","+ast.getPosition(nd).end_line+"]");
                console.log(nd.type + ": " + nd.source());
            }

            // print stmt
            temp = printStmt(nd);

            rtSt = updateSt(rtSt, temp);

            // var temppy = printStmtPy(nd);
            // rtStPy = myupdateSt(rtStPy, temppy);

            numCons++;
            // write file
            smt2FileWrite(rtSt);
            smt2FileWritePy(rtStPy);

        }
    });
    return rtStPy;
}
var esrefactor = require('esrefactor');
var scope_ctx = {};
var sqlInvocations=[];
module.exports = {
    phase: function(root, startHash,filename,code, sqlInvocationsloc) {
        "use strict";
        scope_ctx = new esrefactor.Context(code);
        var pos  = ast.getPosition(root);
        sqlInvocations = sqlInvocationsloc;
    	// console.log("rootstart_line"+pos.start_line);
	      var facts ="";
        //hashVarCnt = startHash+"";
        file = filename;
        // console.log("hashCnt"+hashVarCnt);
        makeGeneralRule();
        facts = traverseCFGM(root);
        //console.log("&&&&&&&&&&&&&&&traverseCFG0    ",traverseCFG0(root), 'color: green; font-weight: bold;');
        facts = facts+'\n'+ traverseCFG0(root);

        facts = facts+'\n'+ printHashVarAll(startHash);
        addQuery();

        consFileWrite();
        // console.log("hashVarToName", hashVarToName);
        //console.log("hashStmt");

             //console.log("myhashVarToName", myhashVarToName);
        // console.log("myhashStmt", myhashStmt);
        return {
          "hashVarCnt":hashVarCnt,
          "myhashVarCnt":myhashVarCnt,
          "toPy":facts
        };
    }
};


/******************************************************************************************/
/**********************************NOT USED NOW********************************************/
/******************************************************************************************/
// Not used now...
function traverseCFG0(root)
{
    "use strict";
    // related with control-dependency //
    var facts="\n";
    iterCFG(root, function (nd) {
            // console.log("traverseCFG0   ", nd.type);
        if(nd.type=== 'ExpressionStatement' || nd.type=== 'ReturnStatement'|| nd.type==='ForStatement'||nd.type==='IfStatement'||nd.type==='FunctionDeclaration'||nd.type==='VariableDeclaration') {
            facts = facts + "\n" + debugStmtSave(nd);
            inverseIpdomObj.insert(nd);
        }
    });
    debugStmtPrint();
    iterCFG(root, function (nd) {
        //constructCD(nd);
        // debugCDSave(nd);
      //facts =  printCD(nd);
    });
    return facts;
}

function traverseCFG1(root)
{
    "use strict";
    // print flow & stmt facts
    iterCFG(root, function (nd) {
        printFlow(nd);
    });
    // I split this for debuging purpose
    iterCFG(root, function (nd) {
        printStmt(nd);
    });
}

function getAllPreds(nd)
{
    "use strict";
    var predArr = [];
    var pred = ast.getAttribute(nd, 'pred');
    if (pred !== undefined) {
        if (pred.length === undefined) {
            predHash = ast.getAttribute(pred, 'hash');
            predArr.push(predHash);
            var update = getAllPreds(pred);
            for (var j=0; j<update.length; j++) {
                predArr.push(update[j]);
            }
        } else {
            for (var i=0; i<pred.length; i++) {
                var predHash = ast.getAttribute(pred[i], 'hash');
                predArr.push(predHash);
                var update = getAllPreds(pred[i]);
                for (var j=0; j<update.length; j++) {
                    predArr.push(update[j]);
                }
            }
        }
    }
    return predArr;
}

/*****************************************************************
   Control dependence construction algorithm
   from Figure 7.10 of Advanced Compiling For High Performance
   -------------------------------
   Procedure ConstructCD(G, CD)
   // G is the input control flow graph
   // CD(x) is the set of blocks on which x is control dependent
   // ipostdom(x) is the immediate postdominator of block x in the
   //   control flow graph G

   L1: find the immediate postdominator relation ipostdom for the control
        flow graph G; (For a control flow graph with a single exit, this
        relation forms a tree, with the exit node as the root.)
       let l be a topological listing of the postdominator tree such that,
        if x postdominates y, then x comes after y in l.

   L2: while l != null do begin
          let x be the first element of l;
          remove x from l;

   L3:    for all control flow predecessors y of x do
              if ipostdom(y) != x then CD(x) = CD(x) + {y};

   L4:    for all z such that ipostdom(z) = x do
              for all y in CD(z) do
                  if ipostdom(y) != x then CD(x) = CD(x) + {y};
       end

   end ConstructCD
*********************************************************************/

/*************************************************
  Functions for control dependency debug
**************************************************/
var debugCDMsg = "";
function debugCDSave(nd)
{
    "use strict";
    var ndHash = ast.getAttribute(nd, 'hash');
    var cd = ast.getAttribute(nd, 'cd');
    debugCDMsg = debugCDMsg + '\n----------------------';
    debugCDMsg = debugCDMsg + "\n Construct with " + ndHash;
    debugCDMsg = debugCDMsg + "\n CD(x): " + cd;
}
function debugCDPrint()
{
    "use strict";
    // var fd = fs.openSync('cdDebug.txt', 'w+');
    // fs.writeSync(fd, debugCDMsg);
}

/*************************************************
  Main function of control dependency construction
**************************************************/
/***
function constructCD(nd)
{
    // ipostdom is ipdom here and ipdom has been made already.
    // And I assume that nd would be the x from l and x comes in regular sequence
    //   as described above.
    // Therefore, I just make L3 and L4 part.
    "use strict";
    if (nd.type === 'Entry') {
        ast.setAttribute(nd, 'cd', []);
        ast.setAttribute(nd, 'mycd', []);
        return;
    }
    //console.log('=====================');
    var cd = [];
    var mycd = [];
    var ndHash = ast.getAttribute(nd, 'hash');
    //console.log("Construct with " + ndHash);
    //var predArr = getAllPreds(nd);
    var predArr = getPreds(nd);
    var mypredArr = getMyPreds(nd);
    // predArr is array of predecessors' hash values
    for (var i=0; i<predArr.length; i++) {
        var predNd = hashStmtObj.getNode(predArr[i]);
        // console.log("@@@@@@@@@@"+nd.source()+"      "+CircularJSON.stringify(predNd));

        var ipdom = ast.getAttribute(predNd, 'ipdom');
        var ipdomHash = ast.getAttribute(ipdom, 'hash');
        if (ndHash !== ipdomHash) {
            var predHash = ast.getAttribute(predNd, 'hash');
            var mypredHash = ast.getAttribute(predNd, 'myhash');
            cd.push(predHash);
            console.log("%%%%"+predHash);
            if(predNd!==undefined) {
                // console.log("%%$%" + getMyHashFromNd(predNd));
                mycd.push(getMyHashFromNd(predNd));
            }
        }else{
            // console.log("%%$%" + getMyHashFromNd(predNd));
            // mycd.push(getMyHashFromNd(predNd));
        }
    }
    //console.log("Midde CD " + cd);

    var inverseIpdomArr = inverseIpdomObj.get(ndHash);
    if (inverseIpdomArr !== undefined) {
        for (i=0; i<inverseIpdomArr.length; i++) {
            var inverseNd = hashStmtObj.getNode(inverseIpdomArr[i]);
            if (inverseNd !== undefined && inverseNd.type !== 'Entry') {
                var cdArr = ast.getAttribute(inverseNd, 'cd');
                if (cdArr === undefined) {
                    ast.setAttribute(inverseNd, 'cd', []);
                    ast.setAttribute(inverseNd, 'mycd', []);
                    cdArr = [];
                }

                //console.log(inverseNd.source());
                console.log("cdArr  "+cdArr);
                for (var j=0; j<cdArr.length; j++) {
                    // cdArr[j] is y's hash value, above algorithm
                    var cdArrNd = hashStmtObj.getNode(cdArr[j]);
                    var ipdomCDArr = ast.getAttribute(cdArrNd, 'ipdom');
                    var hashIpdomCDArr = ast.getAttribute(ipdomCDArr, 'hash');
                    var myhashIpdomCDArr = ast.getAttribute(ipdomCDArr, 'myhash');
                    // hashIpdomCDArr is ipostdom(y)'s hash value
                    if (hashIpdomCDArr !== ndHash) {
                        cd.push(cdArr[j]);
                        // mycd.push(getMyHashFromNd(cdArr[j]));
                        // console.log("cdArr[j]\n"+cdArr[j]);
                        // console.log("myhashIpdomCDArr\n"+myhashIpdomCDArr);
                        if (cdArrNd!==undefined) {

                            // console.log("@@@@cdArrNd\n"+getMyHashFromNd(cdArrNd));
                        }
                    }
                }
            }
        }
    }
    // console.log("Final CD " + cd);
    ast.setAttribute(nd, 'cd', cd);
    ast.setAttribute(nd, 'mycd', mycd);
}
**/

function constructCD(nd)
{
    // ipostdom is ipdom here and ipdom has been made already.
    // And I assume that nd would be the x from l and x comes in regular sequence
    //   as described above.
    // Therefore, I just make L3 and L4 part.
    "use strict";
    if (nd.type === 'Entry') {
        ast.setAttribute(nd, 'cd', []);
        ast.setAttribute(nd, 'mycd', []);
        return;
    }
    //console.log('=====================');
    var cd = [];
    var mycd = [];
    var ndHash = ast.getAttribute(nd, 'hash');

    //var predArr = getAllPreds(nd);
    var predArr = getPreds(nd);
    // console.log("Construct with " + ndHash+"    "+predArr);
    var mypredArr = getMyPreds(nd);
    // predArr is array of predecessors' hash values
    for (var i=0; i<predArr.length; i++) {
        var predNd = hashStmtObj.getNode(predArr[i]);
        var ipdom = ast.getAttribute(predNd, 'ipdom');
        var ipdomHash = ast.getAttribute(ipdom, 'hash');
         // console.log("predNd " + ndHash+"    "+ipdomHash+"       "+ast.getAttribute(predNd,'hash'));
        if (ndHash !== ipdomHash) {
            var predHash = ast.getAttribute(predNd, 'hash');
            var mypredHash = ast.getAttribute(predNd, 'myhash');
            cd.push(predHash);
            console.log("predHash"+predHash);
            mycd.push(mypredHash);
        }
    }
    //console.log("Midde CD " + cd);

    var inverseIpdomArr = inverseIpdomObj.get(ndHash);
    if (inverseIpdomArr !== undefined) {
        for (i=0; i<inverseIpdomArr.length; i++) {
            var inverseNd = hashStmtObj.getNode(inverseIpdomArr[i]);
            if (inverseNd !== undefined && inverseNd.type !== 'Entry') {
                var cdArr = ast.getAttribute(inverseNd, 'cd');
                if (cdArr === undefined) {
                    ast.setAttribute(inverseNd, 'cd', []);
                    ast.setAttribute(inverseNd, 'mycd', []);
                    cdArr = [];
                }

                //console.log(inverseNd.source());

                for (var j=0; j<cdArr.length; j++) {
                    // cdArr[j] is y's hash value, above algorithm
                    var cdArrNd = hashStmtObj.getNode(cdArr[j]);
                    var ipdomCDArr = ast.getAttribute(cdArrNd, 'ipdom');
                    var hashIpdomCDArr = ast.getAttribute(ipdomCDArr, 'hash');
                    var myhashIpdomCDArr = ast.getAttribute(ipdomCDArr, 'myhash');
                    // hashIpdomCDArr is ipostdom(y)'s hash value
                    //   console.log("myhashIpdomCDArr " + hashIpdomCDArr+"    "+ndHash+"       "+cdArr[j]);
                    if (hashIpdomCDArr !== ndHash) {
                        cd.push(cdArr[j]);
                        mycd.push(cdArr[j]);
                    }
                }
            }
        }
    }
    //console.log("Final CD " + cd);
    ast.setAttribute(nd, 'cd', cd);
    ast.setAttribute(nd, 'mycd', mycd);
}

function getPreds(nd)
{
    "use strict";
    var predArr = [];
    var pred = ast.getAttribute(nd, 'pred');
    if (pred !== undefined) {
        if (pred.length === undefined) {
            predHash = ast.getAttribute(pred, 'hash');
            predArr.push(predHash);
        } else {
            for (var i=0; i<pred.length; i++) {
                var predHash = ast.getAttribute(pred[i], 'hash');
                predArr.push(predHash);
            }
        }
    }
    return predArr;
}

function getMyPreds(nd)
{
    "use strict";
    var predArr = [];
    var pred = ast.getAttribute(nd, 'pred');
    if (pred !== undefined) {
        if (pred.length === undefined) {
            predHash = ast.getAttribute(pred, 'myhash');
            predArr.push(predHash);
        } else {
            for (var i=0; i<pred.length; i++) {
                var predHash = ast.getAttribute(pred[i], 'myhash');
                predArr.push(predHash);
            }
        }
    }
    return predArr;
}


/*************************************************
    Functions for control-dep print
**************************************************/
function printCD(nd)
{
    "use strict";
    var cd = ast.getAttribute(nd, 'cd');
    var mycd = ast.getAttribute(nd, 'mycd');
    var hash = ast.getAttribute(nd, 'hash');
    // var myhash = ast.getAttribute(nd, 'myhash');
    var myHash = getMyHashFromNd(nd);
    myHash = getHashVarEndPos(nd, nd.source());
    var rtSt = "";
    for (var i=0; i<cd.length; i++) {
        if (cd[i] === undefined) {
            continue;
        }
        // console.log("================================================");
        // console.log("control info");
        rtSt = updateSt(rtSt, ";;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;");
        rtSt = updateSt(rtSt, "; control info");
        numCons++;
        rtSt = updateSt(rtSt, "(rule (control-dep " + cd[i] + " " + hash +" ))");
        console.log( "(rule (control-dep " + cd[i] + " " + hash +" ))");
        //if(mycd[i][0]=='#') mycd[i] = getDec(mycd[i]);
        // var fact="fp.fact(Stmt(BitVecVal("+getMyHashFromNd(nd)+",lineNum),BitVecVal("+getDec(hash)+",lineNum)))";
        if(mycd[i]!==undefined) {
            var fact = "fp.fact(controldep(BitVecVal(" + mycd[i] + ",lineNum),BitVecVal(" + myHash + ",lineNum)))";
           // var fact = "fp.fact(controldep(BitVecVal(" + myHash + ",lineNum),BitVecVal(" + mycd[i]+ ",lineNum)))";
           console.log("1111" + fact);
           // rtStPy = myupdateSt(rtStPy, fact);
        }
    }
    // write file
    //smt2FileWrite(rtSt);
    smt2FileWritePy(rtStPy);
    // console.log("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@           "+rtStPy);
    return rtStPy;
}
