//
//  ETHZPrintJob+NethzLoader.m
//  VPP
//
//  Created by Nicolas Märki on 06.09.14.
//  Copyright (c) 2014 Nicolas Märki. All rights reserved.
//

#import "ETHZPrintJob+NethzLoader.h"

@implementation ETHZPrintJob (NethzLoader)

- (void)updateNethzData
{
    if(!self.nethzName.length)
    {
        return;
    }

    UIAlertView *alert = [[UIAlertView alloc]
            initWithTitle:@"Nethz-Login"
                  message:NSLocalizedString(@"Wenn du hier dein Passwort eingeben würdest, könnte ich dir "
                                            @"Guthaben und PIN-Code anzeigen. Oder alle deine Mails lesen und "
                                            @"dich in Informatik-Vorlesungen einschreiben, bis du lernst, keine "
                                            @"Kennwörter in Apps von Studenten einzugeben!",
                                            nil)
                 delegate:self
        cancelButtonTitle:@"Abbrechen"
        otherButtonTitles:@"Weiter", nil];
    alert.alertViewStyle = UIAlertViewStyleSecureTextInput;
    [alert textFieldAtIndex:0].placeholder =
        [NSString stringWithFormat:NSLocalizedString(@"Passwort für %@", nil), self.nethzName];

    [alert show];
}

- (NSString *)substringIn:(NSString *)string from:(NSString *)from to:(NSString *)to
{
    NSRange searchStartRange = [string rangeOfString:from];
    if(searchStartRange.length == 0)
    {
        return nil;
    }
    NSRange endRange =
        [string rangeOfString:to
                      options:0
                        range:NSMakeRange(searchStartRange.location + searchStartRange.length,
                                          string.length - searchStartRange.location - searchStartRange.length)];
    if(endRange.length == 0)
    {
        return nil;
    }
    NSString *substring = [string
        substringWithRange:NSMakeRange(searchStartRange.location + searchStartRange.length,
                                       endRange.location - searchStartRange.location - searchStartRange.length)];

    return substring;
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{

    if (buttonIndex == alertView.cancelButtonIndex) {
        return;
    }
    
    NSString *password = [alertView textFieldAtIndex:0].text;

    UIAlertView *blocking = [[UIAlertView alloc] initWithTitle:@""
                                                       message:NSLocalizedString(@"Lädt...", nil)
                                                      delegate:nil
                                             cancelButtonTitle:nil
                                             otherButtonTitles:nil];

    [blocking show];

    __block BOOL codeDone = NO;
    __block BOOL budgetDone = NO;

    [ETHBackend
         loadURL:@"https://idn.ethz.ch/cgi-bin/admin_tool/main.cgi"
          params:nil
          method:@"GET"
        complete:^(AFHTTPRequestOperation *operation, NSError *error)
                 {

            NSString *passwordRand = [self substringIn:operation.responseString from:@"password\" name=\"" to:@"\""];
            NSString *link = [self substringIn:operation.responseString
                                          from:@"https://idn.ethz.ch/cgi-bin/admin_tool/main.cgi/"
                                            to:@"/_top"];

            NSString *login = [self substringIn:operation.responseString from:@"type=\"submit\" name=\"" to:@"\""];

            NSDictionary *params =
                @{@"_login_page": @"1", @"_username": self.nethzName, passwordRand: password, login: @"Login"};

            [ETHBackend
                 loadURL:[NSString stringWithFormat:@"https://idn.ethz.ch/cgi-bin/admin_tool/main.cgi/%@/_top", link]
                  params:params
                  method:@"POST"
                complete:^(AFHTTPRequestOperation *operation2, NSError *error2)
                         {

                    NSString *key = [self substringIn:operation2.responseString from:@"password.fastpl/" to:@"/"];

                    if(!key)
                    {
                        [blocking dismissWithClickedButtonIndex:0 animated:YES];
                        [[[UIAlertView alloc]
                                initWithTitle:NSLocalizedString(@"Fehler", nil)
                                      message:NSLocalizedString(
                                                  @"Irgendwas ist schief gelaufen, versuchs am besten nie wieder.",
                                                  nil)
                                     delegate:nil
                            cancelButtonTitle:@"OK"
                            otherButtonTitles:nil] show];
                    }

                    [ETHBackend
                         loadURL:[NSString
                                     stringWithFormat:@"https://idn.ethz.ch/cgi-bin/admin_tool/vppcode.pl/%@/_top", key]
                          params:nil
                          method:@"GET"
                        complete:^(AFHTTPRequestOperation *operation3, NSError *error3)
                                 {

                            NSString *code = [self substringIn:operation3.responseString
                                                          from:@"Your current pin</i>: <b>"
                                                            to:@"</b>"];
                            if(!code)
                            {
                                if(budgetDone)
                                {
                                    [blocking dismissWithClickedButtonIndex:0 animated:YES];
                                }
                                else
                                {
                                    codeDone = YES;
                                }
                                return;
                            }

                            self.code = code;
                            [self writeToDisk];
                            [self postChangeNotification];
                            if(budgetDone)
                            {
                                [blocking dismissWithClickedButtonIndex:0 animated:YES];
                            }
                            else
                            {
                                codeDone = YES;
                            }
                        }];

                    [ETHBackend
                         loadURL:[NSString
                                     stringWithFormat:@"https://idn.ethz.ch/cgi-bin/admin_tool/credit.fastpl/%@/_top",
                                                      key]
                          params:nil
                          method:@"GET"
                        complete:^(AFHTTPRequestOperation *operation4, NSError *error4)
                                 {

                            NSString *budget = [self
                                substringIn:operation4.responseString
                                       from:@"Freie S/W Seiten</strong>:</td><td bgcolor=\"#EEEEEE\" align=\"right\">"
                                         to:@"</td>"];

                            if(!budget)
                            {
                                if(codeDone)
                                {
                                    [blocking dismissWithClickedButtonIndex:0 animated:YES];
                                }
                                else
                                {
                                    budgetDone = YES;
                                }
                                return;
                            }

                            self.budget = budget;
                            [self writeToDisk];
                            [self postChangeNotification];
                            if(codeDone)
                            {
                                [blocking dismissWithClickedButtonIndex:0 animated:YES];
                            }
                            else
                            {
                                budgetDone = YES;
                            }
                        }];
                }];
        }];
}

@end
