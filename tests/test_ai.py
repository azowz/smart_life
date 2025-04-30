import httpx
import asyncio

class OpenRouterKeyTester:
    def __init__(self, api_key: str):
        self.api_key = "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"  # 👈 ضع المفتاح هنا
        self.api_url = "https://openrouter.ai/api/v1/models"

    async def test_key(self):
        headers = {
            "Authorization": f"Bearer {self.api_key}"
        }

        async with httpx.AsyncClient() as client:
            try:
                response = await client.get(self.api_url, headers=headers)
                response.raise_for_status()
                print("✅ API Key is valid. Available models:")
                for model in response.json().get("data", []):
                    print("-", model.get("id"))
            except Exception as e:
                print("❌ Invalid API Key or an error occurred.")
                print("Details:", str(e))
                if 'response' in locals():
                    print("Response:", response.text)

# 🔽 استدعاء الكلاس واختبار المفتاح
if __name__ == "__main__":
    tester = OpenRouterKeyTester(
        api_key="sk-or-1234567890abcdef..."  # 👈 ضع المفتاح هنا
    )
    asyncio.run(tester.test_key())
