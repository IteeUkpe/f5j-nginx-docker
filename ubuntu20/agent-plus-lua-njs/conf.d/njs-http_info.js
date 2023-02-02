export default { reqall, headers, args, hello, sleep, sleep2};

// two types sleep functions
function isNumber(value) {
  return !Number.isNaN(parseInt(value));
}

// 1 sleep using async / await / Promise
function ms_sleep(milsec) {  return new Promise(function(resolve) {
  let ms ;
  if(!isNumber(milsec)){ ms = 1000; }
  if(isNumber(milsec)){ ms = parseInt(milsec); }
  setTimeout(function(){resolve(ms)}, ms)
})}

async function sleep(r) {
  let ms = await ms_sleep(r.variables.sleep_time_ms)
  r.return(200, "wait " + ms +"msec")

}

// 2 sleep using Promise
function sleep2(r) {
  let ms ;
  if(!isNumber(r.variables.sleep_time_ms)){ ms = 1000; }
  if(isNumber(r.variables.sleep_time_ms)){ ms = parseInt(r.variables.sleep_time_ms); }
  let ms_sleep_promise =  new Promise(function(resolve) {
      setTimeout(function(){resolve()}, ms)
  })
  Promise.all([ms_sleep_promise]).then(function(){
    r.return(200, "wait " + ms +"msec")
  })
}

// hello
function hello(r) {
  r.return(200, "Hello world!\n")
}

// reqall
function reqall(r) {
  let _args = {}
  for (var a in r.args) {
      _args[a] = r.args[a];
  }
  
  
  let str = {
    request: {},
    network: {},
    ssl: {},
    session: {},
    environment: {}
  }
  str.request.headers = r.rawHeadersIn;
  str.request.status = r.status;
  str.request.httpversion = r.httpVersion;
  str.request.method = r.method;
  str.request.scheme = r.variables.scheme;
  str.request.uri = r.uri;
  str.request.args = Object.keys(_args).length ? _args : undefined;
  str.request.requestText = r.requestText;
  str.request.fullPath = r.variables.request_uri;

  str.environment.hostname =  r.variables.hostname;

  str.network.clientPort = r.variables.remote_port;
  str.network.clientAddress = r.variables.remote_addr;
  str.network.serverAddress = r.variables.server_addr;
  str.network.serverPort = r.variables.server_port;

  str.ssl.isHttps = r.variables.Https != 'undefined' && r.variables.Https == 'on' ? true : false;
  str.ssl.sslProtocol = r.variables.sslProtocol != 'undefined' ? r.variables.ssl_protocol : undefined;
  str.ssl.sslCipher = r.variables.sslCipher != 'undefined' ? r.variables.ssl_cipher : undefined;

  str.session.httpConnection = r.variables.http_connection;
  str.session.requestId = r.variables.request_id;
  str.session.connection = r.variables.connection;
  str.session.connectionNumber = r.variables.connection_requests;

  r.return(200, JSON.stringify(str));
  return;
}
function headers(r) {
  let str = r.rawHeadersIn;
  r.return(200, JSON.stringify(str));
  return;
}
function args(r) {
  let str = r.variables.args;
  r.return(200, JSON.stringify(str));
  return;
}