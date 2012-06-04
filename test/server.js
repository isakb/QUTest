/*jshint strict:false*/
/*global process, console*/
// Original code from https://gist.github.com/701407

var http = require("http"),
    url = require("url"),
    path = require("path"),
    fs = require("fs"),
    port = parseInt(process.argv[2], 10) || 8888,
    wwwroot = process.argv[3] || process.cwd(),
    contentTypes = {
        js: "application/javascript",
        css: "text/css",
        html: "text/html"
    },
    getContentType = function(filename) {
        var i = filename.lastIndexOf("."),
            ext, contentType;

        ext = (i < 0) ? "" : filename.substr(i+1);
        contentType = contentTypes[ext];

        return contentType || "text/plain";
    };

http.createServer(function(request, response) {
    var uri = url.parse(request.url).pathname,
        filename = path.join(wwwroot, uri);

    path.exists(filename, function(exists) {
        if (!exists) {
            response.writeHead(404, {"Content-Type": "text/plain"});
            response.end("404 Not Found\n");
            return;
        }
        fs.readFile(filename, "binary", function(err, file) {
            if(err) {
                response.writeHead(500, {"Content-Type": "text/plain"});
                response.end(err + "\n");
                return;
            }
            response.writeHead(200, {"Content-Type": getContentType(filename)});
            response.end(file, "binary");
        });
    });
}).listen(port);

console.log("Static file server running on http://127.0.0.1:" + port + ",\n" +
            "serving files from " + wwwroot + ".\n" +
            "(CTRL + C to exit)\n");

