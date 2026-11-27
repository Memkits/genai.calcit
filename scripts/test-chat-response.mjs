import assert from "node:assert/strict";
import * as core from "../js-out/calcit.core.mjs";
import { chats_create, chat_send_message_$x_, chat_send_message_stream_$x_, extract_text } from "../js-out/genai.sdk.mjs";

const none = core._PCT__$o__$o_(core.Option, core.newTag("none"));
let createRequest;
const created = { name: "offline chat" };
const client = { chats: { create(value) { createRequest = value; return created; } } };
assert.equal(chats_create(client, "fixture-model", none, none), created);
assert.equal(createRequest.model, "fixture-model");
const result = { candidates: [{ content: { parts: [{ text: "offline response" }] } }] };
let request;
const chat = { async sendMessage(value) { request = value; return result; } };
const response = await chat_send_message_$x_(chat, "hello", none);
assert.equal(request.message, "hello");
assert.equal(response, result);
const text = extract_text(response);
assert.equal(text.tag.value, "some");
assert.equal(text.extra[0], "offline response");
await assert.rejects(
  chat_send_message_$x_({ sendMessage: () => Promise.reject(new Error("offline")) }, "hello", none),
  /offline/,
);
const chunks = [{ text: "first" }, { text: "second" }];
const generator = (async function* () { yield* chunks; })();
let streamRequest;
const stream = await chat_send_message_stream_$x_({
  async sendMessageStream(value) { streamRequest = value; return generator; },
}, "stream", none);
assert.equal(streamRequest.message, "stream");
assert.equal(stream, generator);
const received = [];
for await (const chunk of stream) received.push(chunk);
assert.deepEqual(received, chunks);
await assert.rejects(
  chat_send_message_stream_$x_({ sendMessageStream: () => Promise.reject(new Error("stream offline")) }, "stream", none),
  /stream offline/,
);
console.log("Chat responses, streaming and rejection passed");
