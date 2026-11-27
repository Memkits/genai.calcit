import assert from "node:assert/strict";
import * as core from "../js-out/calcit.core.mjs";
import { chat_send_message_$x_, extract_text } from "../js-out/genai.sdk.mjs";

const none = core._PCT__$o__$o_(core.Option, core.newTag("none"));
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
console.log("Chat response and rejection passed");
