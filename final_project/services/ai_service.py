import httpx
from final_project.config import settings

# Function to call the AI API
async def call_ai_api(prompt: str, model: str = "deepseek-chat"):
    api_key = settings.ai["api_key"]
    api_url = settings.ai["api_url"]

    headers = {
        "Authorization": f"Bearer {api_key}",
        "Content-Type": "application/json"
    }

    payload = {
        "model": model,  # Example: "gpt-3.5-turbo" for OpenAI or "deepseek-chat"
        "messages": [{"role": "user", "content": prompt}],
        "temperature": 0.7
    }

    async with httpx.AsyncClient() as client:
        response = await client.post(api_url, headers=headers, json=payload)
        response.raise_for_status()  # Raise exception if request failed
        return response.json()
