import assert from "node:assert/strict";
import { HttpResponse } from "@google/genai";
import * as core from "../js-out/calcit.core.mjs";
import { normalize_count_tokens } from "../js-out/genai.sdk.mjs";

const field = (value, name) => value.nthAt(value.fields.findIndex((tag) => tag.value === name), core.newTag(name));
const some = (value) => {
  assert.equal(value.tag.value, "some");
  return value.extra[0];
};

const response = new Response('{"ok":true}', {
  status: 201,
  headers: { "content-type": "application/json" },
});
const original = new HttpResponse(response);
const result = normalize_count_tokens({ totalTokens: 0, sdkHttpResponse: original });
const http = some(field(result, "sdkHttpResponse"));
assert.equal(http.tag.value, "host");
assert.equal(http.extra[0], original);
assert.equal(http.extra[1], response);
assert.equal(http.extra[1].status, 201);
assert.equal(http.extra[1].headers.get("content-type"), "application/json");
assert.deepEqual(await http.extra[1].json(), { ok: true });
assert.equal(some(field(result, "totalTokens")), 0);
assert.equal(field(normalize_count_tokens({}), "sdkHttpResponse").tag.value, "none");
assert.throws(() => normalize_count_tokens({ sdkHttpResponse: {} }));

const legacyHttp = core._$n__$M_(core.newTag("headers"), core._$n__$M_());
const legacyInput = core._$n__$M_(
  core.newTag("totalTokens"), 3,
  core.newTag("sdkHttpResponse"), legacyHttp,
);
const legacy = normalize_count_tokens(legacyInput);
const legacyResult = some(field(legacy, "sdkHttpResponse"));
assert.equal(legacyResult.tag.value, "legacy");
assert.equal(core._$n__$e_(legacyResult.extra[0], legacyHttp), true);
assert.equal(some(field(legacy, "totalTokens")), 3);
const stringKeys = core._$n__$M_(core.newTag("sdkHttpResponse"), core._$n__$M_("future", 42));
const normalizedLegacy = some(field(normalize_count_tokens(stringKeys), "sdkHttpResponse"));
assert.equal(normalizedLegacy.tag.value, "legacy");
assert.equal(core._$n__$e_(normalizedLegacy.extra[0], core._$n__$M_(core.newTag("future"), 42)), true);
console.log("CountTokens HTTP response and legacy map passed");
