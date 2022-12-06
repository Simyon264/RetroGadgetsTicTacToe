import { Router } from "express";
import { clients, expectedClientVersion } from "../Index";
import { v4 as uuidv4 } from 'uuid';
import { Client } from "../Client";

const router = Router()

router.post("/", (req, res) => {
    // Create a new client and add it to the clients map
    // Send the client's uuid back to the client
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
    const generatedUUID = getFreeUUID();
    clients.set(generatedUUID, new Client(generatedUUID));
    res.status(200).send(JSON.stringify({
        type: "connection",
        uuid: generatedUUID
    }));
    console.log(`Client ${generatedUUID} connected`);
})

function getFreeUUID(): string {
    // Get a free uuid from the clients map
    // Return the uuid if found, else return null
    let didFindFreeUUID = false;
    let freeUUID: string = null;
    while (!didFindFreeUUID) {
        const generatedUUID = uuidv4();
        if (!clients.has(generatedUUID)) {
            freeUUID = generatedUUID;
            didFindFreeUUID = true;
        }
    }

    return freeUUID;
}

export default router;