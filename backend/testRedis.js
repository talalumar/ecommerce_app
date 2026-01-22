import { Redis } from "@upstash/redis";
import "dotenv/config";

const redis = new Redis({
  url: process.env.UPSTASH_REDIS_REST_URL,
  token: process.env.UPSTASH_REDIS_REST_TOKEN,
});

async function test() {
  try {
    await redis.set("health", "ok");
    const value = await redis.get("health");
    console.log("Redis response:", value);
  } catch (err) {
    console.error("Redis error:", err);
  }
}

test();
