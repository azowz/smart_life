import asyncio
import httpx

class OpenRouterAIStandaloneTest:
    def __init__(self):
        self.api_key = "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"
        self.api_url = "https://openrouter.ai/api/v1/chat/completions"
        self.model = "deepseek/deepseek-chat-v3-0324"

    async def run_test(self, prompt: str = "What are the best ways to stay productive?"):
        headers = {
            "Authorization": f"Bearer {self.api_key}",
            "Content-Type": "application/json",
            "HTTP-Referer": "http://localhost",
            "X-Title": "Standalone AI Test",
        }

        payload = {
            "model": self.model,
            "messages": [{"role": "user", "content": prompt}],
            "temperature": 0.7,
            "max_tokens": 800,
        }

        async with httpx.AsyncClient() as client:
            response = await client.post(self.api_url, headers=headers, json=payload)
            response.raise_for_status()
            result = response.json()
            ai_reply = result["choices"][0]["message"]["content"]
            print("\n🧠 AI Response:\n", ai_reply)

# ✅ تنفيذ مباشر إذا شغلت الملف:
if __name__ == "__main__":
    asyncio.run(OpenRouterAIStandaloneTest().run_test())
