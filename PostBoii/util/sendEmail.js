import { SES } from "@aws-sdk/client-ses";

export async function sendEmail(payload) {
    const ses = new SES();
    console.log("Sending email to:", payload.Destination.ToAddresses);
    console.debug("Payload", payload);

    try {
        const data = await ses.sendEmail(payload);
        console.log("Email sent", data);
    } catch (err) {
        console.error("Error sending email", err);
        throw new Error("Error sending email: " + err);
    }
};
