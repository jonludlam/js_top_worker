
fs=require('fs');
vm=require('vm');// vm must be in the global context to work properly


function include(filename){
	var code = fs.readFileSync(filename, 'utf-8');
    vm.runInThisContext(code, filename);
}

function importScripts(filename){
    console.log('importScripts: ' + filename);
	filename='./_opam/'+filename;
	include(filename);
}

global.importScripts=importScripts;
global.include=include;
 