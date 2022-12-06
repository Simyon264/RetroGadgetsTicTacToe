import { Router } from "express";
import { clients, expectedClientVersion } from "../Index";
import { Client } from "../Client";

const router = Router()

router.get("/", (req, res) => {
    // Get all clients from the clients map
    // Send the clients (with lobbies) back to the client
    const clientsArray = Array.from(clients.values());
    const clientsWithLobbies = clientsArray.filter(client => client.Game !== null);
    const clientsWithLobbiesArray = Array.from(clientsWithLobbies.values());
    const clientsWithLobbiesJson: any[] = [];
    clientsWithLobbiesArray.forEach(client => {
        if (typeof client.Game.playerO == "object") {
            clientsWithLobbiesJson.push({
                uuid: client.Game.uuid,
                name: client.Name,
                playerO: client.Game.playerO,
                playerX: client.Game.playerX,
            });
        }
    });

    res.status(200).send(JSON.stringify({
        type: "lobbies",
        lobbies: clientsWithLobbiesJson
    }));
});
export default router;