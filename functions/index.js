const functions = require('firebase-functions');
const admin = require('firebase-admin');
const {onSchedule} = require("firebase-functions/v2/scheduler");

admin.initializeApp();

const db = admin.firestore();
const messaging = admin.messaging();

/**
 * 定期檢查即將到來的事件，並發送通知。
 * 這個 Function 可以設定為定時觸發 (例如使用 Cloud Scheduler)。
 */
exports.sendEventReminders = functions.https.onRequest(async (context) => {
    const now = admin.firestore.Timestamp.now();
    const oneHourLater = new admin.firestore.Timestamp(now.seconds + 3600, now.nanoseconds); // 一小時後的時間

    console.log('開始檢查即將到來的事件...');

    try {
        const eventsSnapshot = await db.collection('calendar_events')
            .where('startTime', '>=', now)
            .where('startTime', '<=', oneHourLater)
            .get();
        console.log('now :', now);
        console.log('one one later :', oneHourLater);
        
        if (eventsSnapshot.empty) {
            console.log('沒有找到即將到來的事件。');
            return null;
        }

        const eventPromises = [];
        eventsSnapshot.forEach(doc => {
            const event = doc.data();
            eventPromises.push(processEvent(event, doc.id)); // 處理每個即將到來的事件
        });

        await Promise.all(eventPromises); // 等待所有事件處理完成
        console.log('已完成事件提醒通知發送。');
        return null;

    } catch (error) {
        console.error('檢查和發送事件提醒時發生錯誤:', error);
        return null;
    }
});

/**
 * 處理單個事件，找出需要通知的使用者並發送通知。
 * @param {object} eventData 事件資料
 * @param {string} eventId 事件 ID
 */
async function processEvent(eventData, eventId) {
    const eventStartTime = eventData.startTime.toDate();
    const eventTitle = eventData.title;
    const creatorId = eventData.creatorId;
    const sharedWith = eventData.sharedWith || [];

    console.log(`處理事件: ${eventTitle} (ID: ${eventId}), 開始時間: ${eventStartTime}`);

    // 取得需要接收通知的用戶 ID 列表 (創建者 + 共享對象)
    const recipientUserIds = new Set([creatorId, ...sharedWith]); // 使用 Set 去重

    const notificationPromises = [];
    for (const userId of recipientUserIds) {
        notificationPromises.push(sendNotificationToUser(userId, eventTitle, eventStartTime, eventId));
    }

    await Promise.all(notificationPromises);
    console.log(`事件 ${eventTitle} (ID: ${eventId}) 的通知已排程發送給 ${recipientUserIds.size} 位使用者。`);
}

/**
 * 發送 FCM 推播通知給指定使用者。
 * @param {string} userId 使用者 ID
 * @param {string} eventTitle 事件標題
 * @param {Date} eventStartTime 事件開始時間
 * @param {string} eventId 事件 ID
 */
async function sendNotificationToUser(userId, eventTitle, eventStartTime, eventId) {
    try {
        const userSnapShot = await db.collection('users')
                                   .where('uid', '==', userId)
                                   .get();
        if (userSnapShot.empty) {
            console.error(`找不到使用者 ${userId}，無法發送通知。`);
            return;
        }
        
        userSnapShot.forEach(async doc => {
            if (!doc.data().fcmToken) {
                console.error(`使用者 ${userId} 沒有設定 FCM Token，無法發送通知。`);
                return;
            }
            const fcmToken = doc.data().fcmToken;
            console.log('event id:', eventId);
            const notificationPayload = {
                notification: {
                    title: '事件提醒：即將開始！',
                    body: `事件 "${eventTitle}" 將在一小時後開始 (${formatTime(eventStartTime)})`,
                },
                data: {
                    eventId: eventId, // 可以選擇性加入事件 ID，方便前端點擊通知後跳轉到事件詳情
                },
                token: fcmToken,
            };
        
            const response = await messaging.send(notificationPayload);
            console.log(`成功發送事件 "${eventTitle}" (ID: ${eventId}) 的提醒通知給使用者 ${userId}，Message ID: ${response.messageId}`);
        });

    } catch (error) {
        console.error(`發送事件 "${eventTitle}" (ID: ${eventId}) 提醒通知給使用者 ${userId} 時發生錯誤:`, error);
    }
}

/**
 * 格式化時間為 HH:mm 格式 (例如 14:30)。
 * @param {Date} date Date 物件
 * @returns {string} 格式化後的時間字串
 */
function formatTime(date) {
    const hours = date.getHours().toString().padStart(2, '0');
    const minutes = date.getMinutes().toString().padStart(2, '0');
    return `${hours}:${minutes}`;
}



// /**
//  * Import function triggers from their respective submodules:
//  *
//  * const {onCall} = require("firebase-functions/v2/https");
//  * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
//  *
//  * See a full list of supported triggers at https://firebase.google.com/docs/functions
//  */

// // const {onRequest} = require("firebase-functions/v2/https");
// // const logger = require("firebase-functions/logger");

// // // Create and deploy your first functions
// // // https://firebase.google.com/docs/functions/get-started

// // // exports.helloWorld = onRequest((request, response) => {
// // //   logger.info("Hello logs!", {structuredData: true});
// // //   response.send("Hello from Firebase!");
// // // });

// const functions = require("firebase-functions");
// const admin = require("firebase-admin");
// const stripe = require("stripe")("sk_test_51QrsraCiI9KAAR1QUvB9wcV2SOpHlHnNU7YrEi3oe4RZCycHhkTiOMcJJ2H3LBA87I1IUibYae017j6PlPaaW4Hx003vaPcG0v");

// admin.initializeApp();

// exports.createPaymentIntent = functions.https.onCall(async (data, context) => {
//     try {
//         const paymentIntent = await stripe.paymentIntents.create({
//             amount: data.amount, // 付款金額（以 cents 為單位）
//             currency: "usd",
//             payment_method_types: ["card"],
//         });

//         return { clientSecret: paymentIntent.client_secret };
//     } catch (error) {
//         console.error("Error creating payment intent:", error);
//         throw new functions.https.HttpsError("internal", error.message);
//     }
// });

