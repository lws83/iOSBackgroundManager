#import "ABBackgroundManager.h"

#define AB_INVALID_TASK ((UIBackgroundTaskIdentifier)-1)

static UIBackgroundTaskIdentifier ABTaskIdentifier =
    AB_INVALID_TASK;

NSString *ABBackgroundManagerVersion(void) {
    return @"1.0.1";
}

void ABRunFiniteBackgroundWork(dispatch_block_t work) {

    if (work == nil) {
        return;
    }

    dispatch_async(dispatch_get_main_queue(), ^{

        UIApplication *app =
            [UIApplication sharedApplication];

        if (ABTaskIdentifier != AB_INVALID_TASK) {
            return;
        }

        __block UIBackgroundTaskIdentifier taskID =
            AB_INVALID_TASK;

        taskID = [app beginBackgroundTaskWithName:
            @"ABBackgroundWork"
            expirationHandler:^{

                if (taskID != AB_INVALID_TASK) {
                    [app endBackgroundTask:taskID];
                    taskID = AB_INVALID_TASK;
                }

                ABTaskIdentifier = AB_INVALID_TASK;
            }];

        ABTaskIdentifier = taskID;

        if (taskID == AB_INVALID_TASK) {
            return;
        }

        dispatch_async(
            dispatch_get_global_queue(QOS_CLASS_UTILITY, 0),
            ^{

                @try {
                    work();
                }
                @finally {

                    dispatch_async(
                        dispatch_get_main_queue(),
                        ^{

                            if (taskID != AB_INVALID_TASK) {
                                [app endBackgroundTask:taskID];
                                taskID = AB_INVALID_TASK;
                            }

                            ABTaskIdentifier =
                                AB_INVALID_TASK;
                        }
                    );
                }
            }
        );
    });
}
