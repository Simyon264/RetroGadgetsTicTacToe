import { Router } from "express";
import { clients, expectedClientVersion } from "../Index";
import { v4 as uuidv4 } from 'uuid';
import { Game } from "../Game";
import { BasicClient } from "../Client";

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
    const generatedUUID = getFreeUUID();
    const client = clients.get(body.clientId);
    if (client) {
        const game = new Game(new BasicClient(client.UUID, client.Name), null, generatedUUID);
        client.Game = game;
        clients.set(body.clientId, client);
        res.status(200).send(JSON.stringify({
            type: "lobby",
            lobbyId: generatedUUID
        }));
        console.log(`Client ${body.clientId} created a lobby with uuid ${generatedUUID}`);
    } else {
        res.status(403).send("Client does not exist.");
    }
})

function getFreeUUID(): string {
    // Gets a free uuid for a lobby
    let didFindFreeUUID = false;
    let freeUUID: string = null;
    while (!didFindFreeUUID) {
        const generatedUUID = uuidv4();
        let isFree = true;
        clients.forEach((client) => {
            if (client.Game?.uuid === generatedUUID) {
                isFree = false;
            }
        });
        if (isFree) {
            freeUUID = generatedUUID;
            didFindFreeUUID = true;
        }
    }

    return freeUUID;
}
export default router;