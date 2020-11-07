import { Injectable } from '@angular/core';
import { NotifierService } from 'angular-notifier';

@Injectable()
export class NotificationService {

    private notifier: NotifierService;
    constructor(notifierService: NotifierService) {
      this.notifier=notifierService;
     }
    
     show(type:string, message:string){
      this.notifier.notify(type, message);
     }

}
