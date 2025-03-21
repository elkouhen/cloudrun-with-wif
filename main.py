import os

from flask import Flask

app = Flask(__name__)


@app.route("/hello")
def hello_world():
    return ("helloworld !")


if __name__ == "__main__":
    print("debug")
    app.run(debug=True, host="0.0.0.0", port=int(os.environ.get("PORT", 8080)))
