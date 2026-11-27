import assert from "node:assert/strict";
import * as core from "../js-out/calcit.core.mjs";
import { ContentConfig, CreateParams, generate_content_$x_, generate_content_stream_$x_, extract_text, interactions_create_$x_, interactions_get_$x_, interactions_cancel_$x_, interactions_delete_$x_ } from "../js-out/genai.sdk.mjs";

const some = (value) => { assert.equal(value.tag.value, "some"); return value.extra[0]; };
const none = core._PCT__$o__$o_(core.Option, core.newTag("none"));
const fields = ["system-instruction", "thinking-config", "tools", "tool-config", "response-modalities", "response-mime-type", "cached-content", "abort-signal", "http-options"];
const config = core._$n__PCT__$M_(ContentConfig, core.newTag("model"), "fixture", core.newTag("contents"), "hello", ...fields.flatMap((name) => [core.newTag(name), none]));
const result = { candidates: [{ content: { parts: [{ text: "offline model" }] } }] };
let request;
const model = { async generateContent(value) { request = value; return result; } };
assert.equal(await generate_content_$x_({ models: model }, config), result);
assert.equal(request.model, "fixture");
assert.equal(request.contents, "hello");
assert.equal(some(extract_text(result)), "offline model");
const chunks = [{ text: "first" }, { text: "second" }];
const generator = (async function* () { yield* chunks; })();
const stream = await generate_content_stream_$x_({ models: { async generateContentStream() { return generator; } } }, config);
assert.equal(stream, generator);
const received = [];
for await (const chunk of stream) received.push(chunk);
assert.deepEqual(received, chunks);
await assert.rejects(generate_content_$x_({ models: { generateContent: () => Promise.reject(new Error("model offline")) } }, config), /model offline/);
await assert.rejects(generate_content_stream_$x_({ models: { generateContentStream: () => Promise.reject(new Error("stream offline")) } }, config), /stream offline/);
const interactionFields = ["system-instruction", "previous-interaction-id", "agent", "background", "store", "generation-config", "tools", "response-modalities", "response-format", "response-mime-type", "abort-signal", "http-options"];
const params = core._$n__PCT__$M_(CreateParams, core.newTag("model"), "fixture", core.newTag("input"), "hello", ...interactionFields.flatMap((name) => [core.newTag(name), none]));
const interaction = { id: "offline-id", status: "completed" };
const deleted = { deleted: true };
let createRequest;
const interactions = {
  async create(value) { createRequest = value; return interaction; },
  async get(id) { assert.equal(id, "offline-id"); return interaction; },
  async cancel(id) { assert.equal(id, "offline-id"); return interaction; },
  async delete(id) { assert.equal(id, "offline-id"); return deleted; },
};
const interactionClient = { interactions };
const getField = (value, name) => value.nthAt(value.fields.findIndex((tag) => tag.value === name), core.newTag(name));
assert.equal(getField(await interactions_create_$x_(interactionClient, params), "id"), "offline-id");
assert.equal(createRequest.model, "fixture");
assert.equal(getField(await interactions_get_$x_(interactionClient, "offline-id"), "id"), "offline-id");
assert.equal(await interactions_cancel_$x_(interactionClient, "offline-id"), interaction);
assert.equal(await interactions_delete_$x_(interactionClient, "offline-id"), deleted);
await assert.rejects(interactions_create_$x_({ interactions: { create: () => Promise.reject(new Error("create offline")) } }, params), /create offline/);
await assert.rejects(interactions_get_$x_({ interactions: { get: () => Promise.reject(new Error("get offline")) } }, "offline-id"), /get offline/);
await assert.rejects(interactions_cancel_$x_({ interactions: { cancel: () => Promise.reject(new Error("cancel offline")) } }, "offline-id"), /cancel offline/);
await assert.rejects(interactions_delete_$x_({ interactions: { delete: () => Promise.reject(new Error("delete offline")) } }, "offline-id"), /delete offline/);
console.log("Model and interaction async responses passed");
