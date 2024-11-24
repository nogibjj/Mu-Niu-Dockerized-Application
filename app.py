from flask import Flask, render_template, jsonify
import random

app = Flask(__name__)

# List of motivational quotes
motivational_quotes = [
    "Push yourself because no one else is going to do it for you.",
    "Great things never come from comfort zones.",
    "Dream it. Believe it. Build it.",
    "Don’t stop when you’re tired. Stop when you’re done.",
    "It’s not about perfect. It’s about effort.",
    "You don’t have to be great to start, but you have to start to be great.",
    "Stay focused and never give up.",
    "Your only limit is you.",
    "Believe you can, and you're halfway there.",
    "You got it ma dawg"
]

@app.route("/")
def home():
    return render_template("index.html")

@app.route("/get_motivation")
def get_motivation():
    quote = random.choice(motivational_quotes)
    return jsonify({"quote": quote})

if __name__ == "__main__":
    app.run(debug=True, host='0.0.0.0')
