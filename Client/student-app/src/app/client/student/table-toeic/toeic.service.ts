import { HttpClient } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { Observable } from 'rxjs';
import { environment } from '../../../../environments/environment';

@Injectable()
export class ToeicService {

  constructor(private http: HttpClient) { }
  
  getScore(): Observable<any[]>{
    const url= environment.apiUrl + '/toeic/get'
    return this.http.get<any[]>(url)
  }

}
