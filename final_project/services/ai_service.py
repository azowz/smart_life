import httpx
from final_project.config import settings

# Call AI service using dynamic settings
async def call_ai_api(prompt: str):
    headers = {
        "Authorization": f"Bearer {settings.ai.api_key}",
        "Content-Type": "application/json",
        "HTTP-Referer": settings.ai.http_referer,
        "X-Title": settings.ai.app_title,
    }

    payload = {
        "model": settings.ai.model,
        "messages": [{"role": "user", "content": prompt}],
        "temperature": settings.ai.temperature,
        "max_tokens": settings.ai.max_tokens,
    }

    async with httpx.AsyncClient() as client:
        response = await client.post(settings.ai.api_url, headers=headers, json=payload)
        response.raise_for_status()
        return response.json()
