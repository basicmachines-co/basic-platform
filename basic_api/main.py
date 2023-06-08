from asgi_htmx import HtmxMiddleware
from fastapi import FastAPI, Request, Response
from fastapi.responses import HTMLResponse
from fastapi.staticfiles import StaticFiles
from fastapi.templating import Jinja2Templates

app = FastAPI()
app.add_middleware(HtmxMiddleware)

app.mount("/static", StaticFiles(directory="static"), name="static")


templates = Jinja2Templates(directory="templates")


@app.get("/", response_class=HTMLResponse, name="index")
async def index(request: Request):
    return templates.TemplateResponse("index.html", {"request": request})


@app.get("/result", name="result")
async def result(request: Request) -> Response:
    assert request.scope["htmx"] is not None
    template = "partials/result.html"
    context = {"request": request, "table": [{"name": "foo", "value": "bar"}]}
    return templates.TemplateResponse(template, context)
