## Run

```
docker build -t shinyapp .
docker run -p 8080:8080 -d shinyapp
```
app should be hosted on http://localhost:8080/