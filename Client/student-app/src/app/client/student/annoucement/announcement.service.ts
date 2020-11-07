import { HttpClient } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { Observable } from 'rxjs';
import { environment } from '../../../../environments/environment';
import { AnnouncementModel } from './annoucement-model';

@Injectable()
export class AnnouncementService {

    constructor( private http:HttpClient) { }

    GetAllByStudent(id):Observable<AnnouncementModel[]>{
        var url= environment.apiUrl + '/notification/getall'
        return this.http.get<AnnouncementModel[]>(url)
    }

}
