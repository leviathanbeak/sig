const replay = @import("replay_api");
const lib = @import("lib");

pub const SIMPLE_CONSENSUS_FINALIZATION_DEPTH: usize = 1;

pub const RootInitialized = extern struct { block: replay.BlockRef };

pub const BlockExecuted = extern struct { block: replay.BlockRef, success: bool };

pub const BlockFinalized = extern struct { block: replay.BlockRef };

pub const ReplayToConsensus = extern struct {
    kind: Kind,
    data: extern union {
        root_initialized: RootInitialized,
        block_executed: BlockExecuted,
    },

    pub const Kind = enum(u8) {
        root_initialized,
        block_executed,
    };

    pub fn rootInitialized(block: replay.BlockRef) ReplayToConsensus {
        return .{
            .kind = .root_initialized,
            .data = .{
                .root_initialized = .{ .block = block },
            },
        };
    }

    pub fn blockExecuted(block: replay.BlockRef, success: bool) ReplayToConsensus {
        return .{
            .kind = .block_executed,
            .data = .{
                .block_executed = .{
                    .block = block,
                    .success = success,
                },
            },
        };
    }
};

pub const Pair = extern struct {
    replay_to_consensus: lib.ipc.Ring(256, ReplayToConsensus),
    consensus_to_replay: lib.ipc.Ring(256, ConsensusToReplay),

    pub fn init(self: *Pair) void {
        self.replay_to_consensus.init();
        self.consensus_to_replay.init();
    }
};

pub const ConsensusToReplay = extern struct {
    kind: Kind,
    data: extern union {
        block_finalized: BlockFinalized,
    },

    pub const Kind = enum(u8) {
        block_finalized,
    };

    pub fn blockFinalized(block: replay.BlockRef) ConsensusToReplay {
        return .{
            .kind = .block_finalized,
            .data = .{
                .block_finalized = .{ .block = block },
            },
        };
    }
};
