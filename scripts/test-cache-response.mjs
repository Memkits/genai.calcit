import assert from "node:assert/strict";
import * as core from "../js-out/calcit.core.mjs";
import { caches_create_$x_, caches_get_$x_, caches_delete_$x_, caches_list_$x_ } from "../js-out/genai.sdk.mjs";

const none = core._PCT__$o__$o_(core.Option, core.newTag("none"));
const content = { name: "cachedContents/test", model: "fixture-model" };
const deleted = { sdkHttpResponse: { status: 200 } };
const pager = { page: [content], async *[Symbol.asyncIterator]() { yield* this.page; } };
const requests = [];
const caches = {
  async create(value) { requests.push(["create", value]); return content; },
  async get(value) { requests.push(["get", value]); return content; },
  async delete(value) { requests.push(["delete", value]); return deleted; },
  async list(value) { requests.push(["list", value]); return pager; },
};
const client = { caches };
assert.equal(await caches_create_$x_(client, "fixture-model", none), content);
assert.equal(await caches_get_$x_(client, "cachedContents/test", none), content);
assert.equal(await caches_delete_$x_(client, "cachedContents/test", none), deleted);
assert.equal(await caches_list_$x_(client, none), pager);
assert.equal(requests[0][1].model, "fixture-model");
assert.equal(requests[1][1].name, "cachedContents/test");
assert.equal(requests[2][1].name, "cachedContents/test");
const results = [];
for await (const item of pager) results.push(item);
assert.deepEqual(results, [content]);
for (const [name, call] of [
  ["create", (c) => caches_create_$x_(c, "fixture-model", none)],
  ["get", (c) => caches_get_$x_(c, "cachedContents/test", none)],
  ["delete", (c) => caches_delete_$x_(c, "cachedContents/test", none)],
  ["list", (c) => caches_list_$x_(c, none)],
]) {
  await assert.rejects(call({ caches: { [name]: () => Promise.reject(new Error(`${name} offline`)) } }), new RegExp(`${name} offline`));
}
console.log("Cache requests, host identity, pager and rejection passed");
