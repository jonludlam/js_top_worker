const worker = new Worker("worker.js")


var promises = new Map()
var id = 1

worker.onmessage = function (e) {
    j = JSON.parse(e.data)
    if (j.id) {
        promise = promises[j.id]
        promises.delete(j.id)
        promise(j.result)
    }
}

function rpc(method, params) {
    const localid = id++;
    return new Promise(function (resolve, reject) {
        worker.postMessage(JSON.stringify({ id:localid, method, params }));
        promises[localid] = resolve
    })
}

function init(cmas,cmi_urls) {
    return rpc("init",[{init_libs:{cmas,cmi_urls}}])
}

function setup() {
    return rpc("setup",[null])
}

function exec(phrase) {
    return rpc("exec",[phrase])
}

function dump(result) {
    console.log(result.stdout)
}

init([],[]).then(() => setup()).then(function(result) { dump(result); exec("let _ = Mime_printer.push \"text/text\" \"hello, world\";;").then((result) => dump(result))})

