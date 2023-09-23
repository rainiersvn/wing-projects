import { SES } from "@aws-sdk/client-ses";

export async function sendEmail(payload) {
    const ses = new SES();
    try {
        const data = await ses.sendEmail(payload);
        return data.$metadata as JSON;
    } catch (err) {
        console.error("Error sending email", err);
        throw new Error("Error sending email: " + err);
    }
};
