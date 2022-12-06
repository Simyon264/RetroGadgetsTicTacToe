import { Router } from "express";
import { clients, expectedClientVersion } from "../Index";

const router = Router()

router.post("/", (req, res) => {
    let body: { GameVersion: string; clientId: string; newName: string | any[]; };
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
        // If the name is over 10 characters, send a 403 error
        if (body.newName.length > 10) {
            res.status(403).send("The name is too long.");
            return;
        }
        // If the name is empty, send a 403 error
        if (body.newName.length === 0) {
            res.status(403).send("The name is empty.");
            return;
        }
        // If the name already exists, send a 403 error
        // const clientsArray = Array.from(clients.values()).filter(client => client.Name === body.newName);
        // if (clientsArray.length > 0) {
        //     res.status(403).send("The name already exists.");
        //     return;
        // }
        // If the name is not empty and is under 19 characters, set the name
        client.LastHeartbeat = 0;
        client.Name = (body.newName as string);
        clients.set(body.clientId, client);
        console.log(`Client ${body.clientId} set their name to ${body.newName}`);
        res.status(200).send(JSON.stringify({
            type: "name"
        }));
    } else {
        // Client does not exist, send a 403 error
        res.status(403).send("Client does not exist.");
    }
})

export default router;