import { Game } from "./Game";

export class Client {
    UUID: string;
    Game?: Game;
    Name: string;
    LastHeartbeat: number;
    constructor(uuid: string) {
        this.UUID = uuid;
        this.Name = "";
        this.LastHeartbeat = 0;
        this.Game = null;
    }
}

export class BasicClient {
    UUID: string;
    Name: string;
    constructor(uuid: string, name: string) {
        this.UUID = uuid;
        this.Name = name;
    }
}