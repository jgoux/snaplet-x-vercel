import fetch from "node-fetch";

const env = process.env;

console.log({ env });

if (process.env.VERCEL_ENV === "preview") {
  const response = await fetch(`https://api.vercel.com/v13/deployments/${process.env.VERCEL_URL}`, {
    headers: {
      "Authorization": `Bearer ${process.env.VERCEL_ACCESS_TOKEN}`,
    },
  }).then(res => res.json());
  console.log(response);
}

process.exit(0);