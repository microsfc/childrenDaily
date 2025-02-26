/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

// const {onRequest} = require("firebase-functions/v2/https");
// const logger = require("firebase-functions/logger");

// // Create and deploy your first functions
// // https://firebase.google.com/docs/functions/get-started

// // exports.helloWorld = onRequest((request, response) => {
// //   logger.info("Hello logs!", {structuredData: true});
// //   response.send("Hello from Firebase!");
// // });

const functions = require("firebase-functions");
const admin = require("firebase-admin");
const stripe = require("stripe")("sk_test_51QrsraCiI9KAAR1QUvB9wcV2SOpHlHnNU7YrEi3oe4RZCycHhkTiOMcJJ2H3LBA87I1IUibYae017j6PlPaaW4Hx003vaPcG0v");

admin.initializeApp();

exports.createPaymentIntent = functions.https.onCall(async (data, context) => {
    try {
        const paymentIntent = await stripe.paymentIntents.create({
            amount: data.amount, // 付款金額（以 cents 為單位）
            currency: "usd",
            payment_method_types: ["card"],
        });

        return { clientSecret: paymentIntent.client_secret };
    } catch (error) {
        console.error("Error creating payment intent:", error);
        throw new functions.https.HttpsError("internal", error.message);
    }
});

