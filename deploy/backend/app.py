# from email.policy import strict
from defer import return_value
from flask import Flask, request, jsonify

from flask_cors import CORS
import flatpak

# Init app
app = Flask(__name__)
CORS(app)

# # Get all installed Applications
# @app.route('/flatpak/installed', methods=['GET'])
# def get_installed_applications():
#     installed_application_ids = flatpak.get_installed_applications()
#     return jsonify(flatpak.get_information_about_applications(installed_application_ids))

# Get all Applications
@app.route('/flatpak/all', methods=['GET'])
def get_all_available_applications():
    return jsonify(flatpak.get_all_available_applications())

# Install Application
@app.route('/flatpak/install/<app_id>', methods=['GET'])
def install_application(app_id):
    flatpak.install_application(app_id)
    return jsonify({"msg": "success"})

# Remove Application
@app.route('/flatpak/remove/<app_id>', methods=['GET'])
def remove_application(app_id):
    flatpak.remove_application(app_id)
    return jsonify({"msg": "success"})

# Start Application
@app.route('/flatpak/start/<app_id>', methods=['GET'])
def start_application(app_id):
    flatpak.start_application(app_id)
    return jsonify({"msg": "success"})

# Run Server
if __name__ == '__main__':
    # app.run(debug = True)
    # For Deployment:
    from waitress import serve
    serve(app, host="0.0.0.0", port=5000)
