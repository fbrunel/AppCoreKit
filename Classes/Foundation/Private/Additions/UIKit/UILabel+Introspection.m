//
//  UILabel+Introspection.m
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright 2011 Wherecloud. All rights reserved.
//

#import "UILabel+Introspection.h"
#import "NSValueTransformer+Additions.h"
#import "CKPropertyExtendedAttributes+Attributes.h"


@implementation UILabel (CKIntrospectionAdditions)

- (void)textAlignmentExtendedAttributes:(CKPropertyExtendedAttributes*)attributes{
	attributes.enumDescriptor = CKEnumDefinition(@"UITextAlignment",
                                               UITextAlignmentLeft,
											   UITextAlignmentCenter,
											   UITextAlignmentRight);
}

- (void)lineBreakModeExtendedAttributes:(CKPropertyExtendedAttributes*)attributes{
	attributes.enumDescriptor = CKEnumDefinition(@"UILineBreakMode",
                                               UILineBreakModeWordWrap,
											   UILineBreakModeCharacterWrap,
											   UILineBreakModeClip,
											   UILineBreakModeHeadTruncation,
											   UILineBreakModeTailTruncation,
											   UILineBreakModeMiddleTruncation,
                                                 NSLineBreakByWordWrapping,
                                                 NSLineBreakByCharWrapping,
                                                 NSLineBreakByClipping,
                                                 NSLineBreakByTruncatingHead,
                                                 NSLineBreakByTruncatingTail,
                                                 NSLineBreakByTruncatingMiddle);
}

- (void)baselineAdjustmentExtendedAttributes:(CKPropertyExtendedAttributes*)attributes{
	attributes.enumDescriptor = CKEnumDefinition(@"UIBaselineAdjustment",
                                               UIBaselineAdjustmentAlignBaselines,
											   UIBaselineAdjustmentAlignCenters,
											   UIBaselineAdjustmentNone);
}

- (void)textExtendedAttributes:(CKPropertyExtendedAttributes*)attributes{
    attributes.multiLineEnabled = YES;
}


@end
