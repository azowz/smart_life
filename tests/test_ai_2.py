import asyncio
import httpx
import os  # For environment variables

class OpenRouterAIStandaloneTest:
    def __init__(self):
        # Always use environment variables for API keys in production!
        self.api_key = os.getenv("OPENROUTER_API_KEY", "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")
        self.api_url = "https://openrouter.ai/api/v1/chat/completions"
        self.model = "deepseek/deepseek-chat"  # Correct OpenRouter model format

    async def run_test(self, prompt: str = "ما هي عاصمة السعودية؟"):
        headers = {
            "Authorization": f"Bearer {self.api_key}",
            "Content-Type": "application/json",
            "HTTP-Referer": "http://localhost:3000",  # Required by OpenRouter
            "X-Title": "AI Test App",                # Required by OpenRouter
            "User-Agent": "MyPythonApp/1.0"         # Recommended
        }

        payload = {
            "model": self.model,
            "messages": [{"role": "user", "content": prompt}],
            "temperature": 0.7,
            "max_tokens": 800
        }

        try:
            async with httpx.AsyncClient(timeout=30.0) as client:
                print("🚀 Sending request to OpenRouter...")
                response = await client.post(
                    self.api_url,
                    headers=headers,
                    json=payload
                )
                
                # Debugging output
                print(f"🔧 Status Code: {response.status_code}")
                
                response.raise_for_status()
                result = response.json()

                if "choices" in result and result["choices"]:
                    message = result["choices"][0]["message"]["content"]
                    print("\n🤖 AI Response:\n", message)
                else:
                    print("⚠️ Unexpected response format:", result)
        
        except httpx.HTTPStatusError as e:
            print(f"❌ HTTP Error {e.response.status_code}: {e.response.text}")
            if e.response.status_code == 400:
                print("Tip: Check your model name at https://openrouter.ai/models")
        except Exception as e:
            print(f"❌ Unexpected Error: {type(e).__name__}: {str(e)}")

if __name__ == "__main__":
    # Example Arabic prompt
    asyncio.run(OpenRouterAIStandaloneTest().run_test("كيف يمكنني تحسين كفاءة البرمجة؟"))
#"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"