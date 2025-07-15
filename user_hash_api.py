# user_hash_api.py
from flask import Flask, request, jsonify
import hmac
import hashlib
import os

app = Flask(__name__)

# Replace with your actual Chatbase secret key
CHATBASE_SECRET = "your_chatbase_secret_here"

@app.route('/get_user_hash', methods=['POST'])
def generate_user_hash():
    user_id = request.args.get('userId')
    if not user_id:
        return jsonify({'error': 'Missing userId'}), 400

    user_hash = hmac.new(
        key=CHATBASE_SECRET.encode('utf-8'),
        msg=user_id.encode('utf-8'),
        digestmod=hashlib.sha256
    ).hexdigest()

    return jsonify({'userId': user_id, 'userHash': user_hash})


if __name__ == '__main__':
    app.run(debug=True)
