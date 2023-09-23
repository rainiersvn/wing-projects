const crypto = require('crypto');

export function randomUUID() {
    return crypto.randomUUID({ disableEntropyCache: true });
}

export function createdDate() {
    return new Date().toISOString();;
}

export function extractJson(json, key) {
    return JSON.parse(json)[key];
}
