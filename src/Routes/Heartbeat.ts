import { Router } from "express";
import { clients, expectedClientVersion } from "../Index";
import { v4 as uuidv4 } from 'uuid';
import { Client } from "../Client";

const router = Router()

router.post("/", (req, res) => {
    let body;
    try {
        body = JSON.parse(Object.keys(req.body)[0]);
    } catch (error) {
        body = req.body;
    }
    if (body.GameVersion !== expectedClientVersion) {
        res.status(418).send("The client version is not compatible with the server version.");
        return;
    }

    // Get client from clients map
    const client = clients.get(body.clientId);
    if (client) {
        // Client exists
        client.LastHeartbeat = 0;
        clients.set(body.clientId, client);
        res.status(200).send(JSON.stringify({
            type: "heartbeat"
        }));
    } else {
        // Client does not exist, send a 403 error
        res.status(403).send("Client does not exist.");
    }
})

export default router;