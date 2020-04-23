var stage1 = require('./stage1');
var stage2 = require('./stage2');
var cfgRelated = require('./cfg');
var fs = require('fs');
var filename = "./test_norm.js";
filename = process.argv[2];
var code = fs.readFileSync(filename).toString();

// run stage1 and make normalized code
var normalized = code;
console.log(normalized);

//return;
//return;
//normalized = code;
//return;
/**
console.log(normalized);

fs.writeFile('./test_norm.js', normalized, (err) => {
	    // throws an error, you could also catch it here
	    if (err) throw err;

	        // success case, the file was saved
	        console.log('Lyric saved!');
});
**/
var code_norm = normalized;
//var code_norm = fs.readFileSync('./test_norm.js').toString();

//return;

    var cfg = cfgRelated.makeCFG(code_norm);
    // build dominator tree using JS_WALA
    cfgRelated.buildDominatorTrees(cfg, true);
    // Print all facts by traversing CFG
    //var result = stage2.phase(cfg,0,'./test_norm.js');
    var result = stage2.phase(cfg,0,filename,code_norm);
    console.log("#####@@@@@@@@@\n\n\n"+result.toPy);

// stage2.phase();
