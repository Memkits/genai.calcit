import assert from "node:assert/strict";
import * as core from "../js-out/calcit.core.mjs";
import { caches_create_$x_, caches_get_$x_, caches_delete_$x_, caches_list_$x_, files_upload_$x_, files_get_$x_, files_delete_$x_, files_list_$x_ } from "../js-out/genai.sdk.mjs";

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
const uploaded = { name: "files/test", mimeType: "text/plain", uri: "https://example.invalid/file" };
const filePager = { page: [uploaded], async *[Symbol.asyncIterator]() { yield* this.page; } };
const fileRequests = [];
const files = {
  async upload(value) { fileRequests.push(["upload", value]); return uploaded; },
  async get(value) { fileRequests.push(["get", value]); return uploaded; },
  async delete(value) { fileRequests.push(["delete", value]); return deleted; },
  async list(value) { fileRequests.push(["list", value]); return filePager; },
};
const fileClient = { files };
const blob = new Blob(["synthetic"], { type: "text/plain" });
assert.equal(await files_upload_$x_(fileClient, "fixture.txt", none), uploaded);
assert.equal(await files_upload_$x_(fileClient, blob, none), uploaded);
assert.equal(fileRequests[0][1].file, "fixture.txt");
assert.equal(fileRequests[1][1].file, blob);
assert.equal(await files_get_$x_(fileClient, "files/test", none), uploaded);
assert.equal(await files_delete_$x_(fileClient, "files/test", none), deleted);
assert.equal(await files_list_$x_(fileClient, none), filePager);
assert.equal(fileRequests[2][1].name, "files/test");
assert.equal(fileRequests[3][1].name, "files/test");
const fileResults = [];
for await (const item of filePager) fileResults.push(item);
assert.deepEqual(fileResults, [uploaded]);
for (const [name, call] of [
  ["upload", (c) => files_upload_$x_(c, "fixture.txt", none)],
  ["get", (c) => files_get_$x_(c, "files/test", none)],
  ["delete", (c) => files_delete_$x_(c, "files/test", none)],
  ["list", (c) => files_list_$x_(c, none)],
]) {
  await assert.rejects(call({ files: { [name]: () => Promise.reject(new Error(`${name} offline`)) } }), new RegExp(`${name} offline`));
}
console.log("Cache and file requests, host identity, pagination and rejection passed");
