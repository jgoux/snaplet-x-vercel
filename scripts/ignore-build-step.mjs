import fetch from "node-fetch";

if (process.env.VERCEL_ENV === "preview") {
  const deployment = await fetch(`https://api.vercel.com/v13/deployments/${process.env.VERCEL_URL}`, {
    headers: {
      "Authorization": `Bearer ${process.env.VERCEL_ACCESS_TOKEN}`,
    },
  }).then(res => res.json());

  if (!deployment?.meta?.deployHookId) {
    process.exit(0);
  }
}

process.exit(1);