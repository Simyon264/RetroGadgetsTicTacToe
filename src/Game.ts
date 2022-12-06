import { BasicClient } from "./Client";

export class Game {
    lastUpdate: number; // If this value is too high the game will be considered as inactive and will be deleted
    lastUpdateO: number;
    playerX: BasicClient;
    playerO: BasicClient;
    turn: "X" | "O";
    board: ("X" | "O" | "")[];
    uuid: string;
    Rematch: {
        X: boolean;
        O: boolean;
    };
    Winner: "X" | "O" | "Tie" | "" | null = null;
    constructor(playerX: BasicClient, playerO: BasicClient, uuid: string) {
        this.lastUpdate = 0;
        this.lastUpdateO = 0;
        this.playerX = playerX;
        this.playerO = playerO;
        this.uuid = uuid;
        this.Rematch = {
            X: false,
            O: false,
        };
        this.turn = "X";
        this.board = ["", "", "", "", "", "", "", "", ""];
    }
}