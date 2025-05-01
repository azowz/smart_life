import os
import secrets
from dynaconf import Dynaconf

# ✨ Load Settings
HERE = os.path.dirname(os.path.abspath(__file__))

settings = Dynaconf(
    envvar_prefix="final_project",
    preload=[os.path.join(HERE, "default.toml")],
    settings_files=[
        os.path.join(HERE, "settings.toml"),
        os.path.join(HERE, ".secrets.toml"),
    ],
    environments=True,
    env="default",  # Ensures [default] section is loaded
    env_switcher="final_project_env",
    load_dotenv=True,
)

# ✅ Secure secret key setup
if not settings.get("security.secret_key"):
    secret_key = os.environ.get("FINAL_PROJECT_SECRET_KEY")
    if not secret_key:
        secret_key = secrets.token_hex(32)
        print("⚠️ WARNING: Using auto-generated secret key. For production, set FINAL_PROJECT_SECRET_KEY!")
    settings.set("security.secret_key", secret_key)

# ✅ Validate AI config
if not settings.get("ai.api_key") or not settings.get("ai.api_url"):
    print("❌ AI configuration is missing! Please check [default.ai] in default.toml")

"""
✅ How to use in your project:

from final_project.config import settings

settings.security.secret_key
settings.db.uri
settings.ai.api_key
settings.ai.api_url
settings.ai.model
settings.ai.http_referer
settings.ai.app_title
settings.ai.temperatureQ
settings.ai.max_tokens
"""
