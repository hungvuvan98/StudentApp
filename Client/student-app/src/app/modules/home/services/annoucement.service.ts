import { Injectable } from '@angular/core';
import { Observable } from 'rxjs';
import {environment} from '../../../../environments/environment'
import { HttpClient } from '@angular/common/http';
import { Announcement } from '../models/announcement';

@Injectable()
export class AnnouncementService {

constructor( private http:HttpClient) { }

GetAllByStudent(id):Observable<Announcement[]>{
    var url= environment.apiUrl + '/notification/getbystudent/' + id
    return this.http.get<Announcement[]>(url)
}

}
