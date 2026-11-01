#import "ABBackgroundManager.h"

static UIBackgroundTaskIdentifier ABTaskIdentifier =
    UIBackgroundTaskInvalid;

NSString *ABBackgroundManagerVersion(void) {
    return @"1.0.0";
}

void ABRunFiniteBackgroundWork(dispatch_block_t work) {

    if (!work) return;

    dispatch_async(dispatch_get_main_queue(), ^{

        UIApplication *app =
            [UIApplication sharedApplication];

        if (ABTaskIdentifier != UIBackgroundTaskInvalid) {
            return;
        }

        __block UIBackgroundTaskIdentifier taskID =
            UIBackgroundTaskInvalid;

        taskID = [app beginBackgroundTaskWithName:
            @"ABBackgroundWork"
            expirationHandler:^{

                if (taskID != UIBackgroundTaskInvalid) {
                    [app endBackgroundTask:taskID];
                    taskID = UIBackgroundTaskInvalid;
                    ABTaskIdentifier = UIBackgroundTaskInvalid;
                }
            }];

        ABTaskIdentifier = taskID;

        if (taskID == UIBackgroundTaskInvalid) return;

        dispatch_async(
            dispatch_get_global_queue(QOS_CLASS_UTILITY, 0),
            ^{

                @try {
                    work();
                }
                @finally {
                    dispatch_async(dispatch_get_main_queue(), ^{

                        if (taskID != UIBackgroundTaskInvalid) {
                            [app endBackgroundTask:taskID];
                            taskID = UIBackgroundTaskInvalid;
                            ABTaskIdentifier = UIBackgroundTaskInvalid;
                        }
                    });
                }
            }
        );
    });
}
