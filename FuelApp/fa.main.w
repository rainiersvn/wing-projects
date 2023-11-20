bring cloud;
bring util;
bring http;

let website = new cloud.Website(
    path: "./website",
    domain: "fuel.app.cloudkid.link",
);

let api = new cloud.Api({
    cors: true,
    corsOptions: {
        allowHeaders: ["*"],
        allowMethods: [http.HttpMethod.POST, http.HttpMethod.GET],
    },
});
website.addJson("config.json", { api: api.url });

let counter = new cloud.Counter() as "website-counter";

api.post("/hello-static", inflight (request) => {
    return {
        status: 200,
        headers: {
        "Content-Type" => "text/html",
        "Access-Control-Allow-Origin" => "*",
        },
        body: "<div id=\"hello\" class=\"mt-4\">Hello ${counter.inc()}</div>",
    };
});

api.get("/about", inflight (request) => {
    return {
        status: 200,
        headers: {
        "Content-Type" => "text/html",
        "Access-Control-Allow-Origin" => "*",
        },
        body: "FuelApp API is running",
    };
});
