import asyncio

import aiohttp


async def fetch():
    async with aiohttp.ClientSession() as session:
        async with session.get('https://www.google.com/robots.txt') as resp:
            await resp.text()


loop = asyncio.get_event_loop()
loop.run_until_complete(fetch())
