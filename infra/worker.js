addEventListener("fetch", event => {
    event.respondWith(handle(event.request));
});

async function handle(request) {
    try {
        // Only POST allowed
        if (request.method !== "POST") {
            return new Response("OK", { status: 200 });
        }

        // Try parse JSON safely
        let data;
        try {
            const text = await request.text();
            data = JSON.parse(text);
        } catch (e) {
            return new Response("INVALID_JSON", { status: 200 });
        }

        const message = data?.message;
        if (!message || !message.text) {
            return new Response("NO_MESSAGE", { status: 200 });
        }

        const chatId = message.chat.id;
        const text = message.text.trim();

        if (text.startsWith("/task")) {
            const title = text.replace("/task", "").trim();

            if (!title) {
                await sendTelegram(chatId, "❌ Bạn chưa nhập nội dung task.");
                return new Response("OK");
            }

            const created = await createTrelloCard(title);

            if (created?.id) {
                await sendTelegram(chatId, `✅ Tạo task thành công:\n${created.url}`);
            } else {
                await sendTelegram(chatId, "❌ Không thể tạo task trên Trello.");
            }

            return new Response("OK");
        }

        // Fallback
        await sendTelegram(chatId, "⚙️ Dùng lệnh: /task <nội dung>");
        return new Response("OK");

    } catch (err) {
        return new Response("ERROR: " + err.message, { status: 500 });
    }
}


// ===========================================================
// Helper functions
// ===========================================================

async function sendTelegram(chatId, text) {
    const url = `https://api.telegram.org/bot${TELEGRAM_TOKEN}/sendMessage`;
    const payload = JSON.stringify({ chat_id: chatId, text });

    return fetch(url, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: payload
    });
}

async function createTrelloCard(title) {
    const url =
        `https://api.trello.com/1/cards` +
        `?key=${TRELLO_KEY}` +
        `&token=${TRELLO_TOKEN}`;

    const body = new URLSearchParams({
        idList: TRELLO_LIST_ID,
        name: title,
    });

    const res = await fetch(url, {
        method: "POST",
        body
    });

    return res.json();
}
