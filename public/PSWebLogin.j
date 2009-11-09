@import <Foundation/CPObject.j>

@implementation PSWebLogin
{
    CPString username    @accessors;
    CPString password    @accessors;
    CPString url         @accessors;
}

- (id)initWithJSONObject:(JSObject)anObject
{
    if (self = [super init])
    {
        username = anObject.username;
        password = anObject.password;
        url      = anObject.url;
    }
    return self;
}

+ (CPArray)initWithJSONObjects:(CPArray)someJSONObjects
{
    var webLogins = [[CPArray alloc] init];
    for (var i=0; i < someJSONObjects.length; i++) {
        var webLogin = [[PSWebLogin alloc] initWithJSONObject:someJSONObjects[i]];
        [webLogins addObject:webLogin];
    };
    return webLogins;
}
@end